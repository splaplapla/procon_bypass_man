class ProconBypassMan::BypassCommand
  include ProconBypassMan::SignalHandler

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
    t1 = Thread.new do
      timer = ProconBypassMan::Timer.new(timeout: Time.now + 10)
      bypass = ProconBypassMan::Bypass.new(gadget: @gadget, procon: @procon, monitor: monitor1)
      loop do
        break if $will_terminate_token
        timer.throw_if_timeout!
        bypass.send_gadget_to_procon!
        sleep(0.005)
      rescue ProconBypassMan::Timer::Timeout
        ProconBypassMan.logger.info "10秒経過したのでThread1を終了します"
        monitor1.shutdown
        puts "10秒経過したのでThread1を終了します"
        break
      rescue Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError => e
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
        break if $will_terminate_token
        bypass.send_procon_to_gadget!
      rescue EOFError => e
        ProconBypassMan::SendErrorCommand.execute(error: "Proconが切断されました。終了処理を開始します. #{e.full_message}")
        Process.kill "TERM", Process.ppid
      rescue Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError => e
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
    rescue Interrupt
      $will_terminate_token = true
      [t1, t2].each(&:join)
      @gadget&.close
      @procon&.close
      exit 1
    end
  end
end
