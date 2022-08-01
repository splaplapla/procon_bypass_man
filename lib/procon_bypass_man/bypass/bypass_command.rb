class ProconBypassMan::BypassCommand
  include ProconBypassMan::SignalHandler

  module WILL_TERMINATE_TOKEN
    TERMINATE = :terminate
    RESTART = :restart
  end

  def initialize(gadget: , procon: )
    @gadget = gadget
    @procon = procon

    ProconBypassMan::Background::JobRunner.queue.clear # forkしたときに残留物も移ってしまうため
    ProconBypassMan::Background::JobRunner.start!
  end

  def execute
    self_read, self_write = IO.pipe
    %w(TERM INT USR2).each do |sig|
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
    ProconBypassMan.logger.info "Thread1を起動します"

    cycle_sleep = ProconBypassMan::CycleSleep.new(cycle_interval: 1, execution_cycle: ProconBypassMan.config.bypass_mode.gadget_to_procon_interval)

    t1 = Thread.new do
      if ProconBypassMan.config.bypass_mode.mode == ProconBypassMan::BypassMode::TYPE_AGGRESSIVE
        ProconBypassMan.logger.info "TYPE_AGGRESSIVEなのでThread1を終了します"
        next
      end

      bypass = ProconBypassMan::Bypass::SwitchToProcon.new(gadget: @gadget, procon: @procon)
      loop do
        break if $will_terminate_token

        cycle_sleep.sleep_or_execute do
          bypass.run
        end
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
    t2 = Thread.new do
      bypass = ProconBypassMan::Bypass::ProconToSwitch.new(gadget: @gadget, procon: @procon)
      process = BlueGreenProcess.new(
        worker_instance: bypass,
        max_work: 60 * 71 * 2, # 60秒間に71回くらいバイパスするので2秒くらいで入れ替える
      )
      loop do
        if $will_terminate_token
          if $will_terminate_token == WILL_TERMINATE_TOKEN::TERMINATE
            bypass.direct_connect_switch_via_bluetooth
            process.shutdown
          end
          break
        end

        process.work
      rescue EOFError => e
        ProconBypassMan::SendErrorCommand.execute(error: "Proconが切断されました。終了処理を開始します. #{e.full_message}")
        Process.kill "TERM", Process.ppid
        process.shutdown
        break
      rescue Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError, Errno::ESHUTDOWN => e
        ProconBypassMan::SendErrorCommand.execute(error: "Proconが切断されました。終了処理を開始します2. #{e.full_message}")
        Process.kill "TERM", Process.ppid
        process.shutdown
        break
      end
    end

    ProconBypassMan.logger.info "子プロセスでgraceful shutdownの準備ができました"
    begin
      while(readable_io = IO.select([self_read]))
        signal = readable_io.first[0].gets.strip
        handle_signal(signal)
      end
    rescue ProconBypassMan::Runner::InterruptForRestart
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
