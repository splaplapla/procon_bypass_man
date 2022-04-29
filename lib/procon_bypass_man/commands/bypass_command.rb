class ProconBypassMan::BypassCommand
  include ProconBypassMan::SignalHandler

  module WILL_TERMINATE_TOKEN
    TERMINATE = :terminate
    RESTART = :restart
  end

  def initialize(gadget:, procon:)
    @gadget = gadget
    @procon = procon

    ProconBypassMan::IOMonitor.start!
    ProconBypassMan::Background::JobRunner.queue.clear # forkしたときに残留物も移ってしまうため
    ProconBypassMan::Background::JobRunner.start!
  end

  def execute
    self_read, self_write = IO.pipe
    %w(TERM INT).each do |sig|
      begin
        trap sig do
          self_write.puts(sig)
        end
      rescue ArgumentError
        puts "プロセスでSignal #{sig} not supported"
      end
    end

    # gadget => procon
    # 遅くていい
    monitor1 = ProconBypassMan::IOMonitor.new(label: "switch -> procon")
    monitor2 = ProconBypassMan::IOMonitor.new(label: "procon -> switch")
    ProconBypassMan.logger.info "Thread1を起動します"

    @send_interval = 0.005

    t1 = Thread.new do
      timer = ProconBypassMan::SafeTimeout.new(timeout: Time.now + 10)
      @did_first_step = false
      loop do
        bypass = ProconBypassMan::Bypass.new(gadget: @gadget, procon: @procon, monitor: monitor1)
        break if $will_terminate_token
        !@did_first_step && timer.throw_if_timeout!
        bypass.send_gadget_to_procon!
        sleep(@send_interval)
      rescue ProconBypassMan::SafeTimeout::Timeout
        case ProconBypassMan.config.bypass_mode.mode
        when ProconBypassMan::BypassMode::TYPE_AGGRESSIVE
          ProconBypassMan.logger.info "10秒経過したのでThread1を終了します"
          monitor1.shutdown
          break
        when ProconBypassMan::BypassMode::TYPE_NORMAL
          ProconBypassMan.logger.info "10秒経過したのでsend_intervalを長くします"
          @send_interval = ProconBypassMan.config.bypass_mode.gadget_to_procon_interval
        else
          raise "unknown type"
        end
        @did_first_step = true
      rescue Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError, Errno::ESHUTDOWN => e
        ProconBypassMan::SendErrorCommand.execute(error: "Switchとの切断されました.終了処理を開始します. #{e.full_message}")
        Process.kill "TERM", Process.ppid
      rescue Errno::ETIMEDOUT => e
        # TODO まれにこれが発生する. 再接続したい
        ProconBypassMan::SendErrorCommand.execute(error: "Switchと意図せず切断されました.終了処理を開始します. #{e.full_message}")
        Process.kill "TERM", Process.ppid
      end
      ProconBypassMan.logger.info "Thread1を終了します"
    end

    # procon => gadget
    # シビア
    ProconBypassMan.logger.info "Thread2を起動します"
    t2 = Thread.new do
      bypass = ProconBypassMan::Bypass.new(gadget: @gadget, procon: @procon, monitor: monitor2)
      loop do
        if $will_terminate_token
          if $will_terminate_token == WILL_TERMINATE_TOKEN::TERMINATE
            bypass.direct_connect_switch_via_bluetooth
            bypass.be_empty_procon
          end
          break
        end

        bypass.send_procon_to_gadget!
      rescue EOFError => e
        ProconBypassMan::SendErrorCommand.execute(error: "Proconが切断されました。終了処理を開始します. #{e.full_message}")
        Process.kill "TERM", Process.ppid
      rescue Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError, Errno::ESHUTDOWN => e
        ProconBypassMan::SendErrorCommand.execute(error: "Proconが切断されました。終了処理を開始します2. #{e.full_message}")
        Process.kill "TERM", Process.ppid
      end
      ProconBypassMan.logger.info "Thread2を終了します"
    end

    ProconBypassMan.logger.info "子プロセスでgraceful shutdownの準備ができました"
    begin
      while(readable_io = IO.select([self_read]))
        signal = readable_io.first[0].gets.strip
        handle_signal(signal)
      end
    rescue InterruptForRestart
      $will_terminate_token = WILL_TERMINATE_TOKEN::RESTART
      [t1, t2].each(&:join)
      @gadget&.close
      @procon&.close
      exit! 1 # child processなのでexitしていい
    rescue Interrupt
      $will_terminate_token = WILL_TERMINATE_TOKEN::TERMINATE
      [t1, t2].each(&:join)
      @gadget&.close
      @procon&.close
      exit! 1 # child processなのでexitしていい
    end
  end
end
