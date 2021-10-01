class ProconBypassMan::Bypass
  attr_accessor :gadget, :procon, :monitor
  attr_accessor :mutex

  def initialize(gadget: , procon: , monitor: )
    self.gadget = gadget
    self.procon = procon
    self.monitor = monitor
    self.mutex = ::Thread::Mutex.new
  end

  # ゆっくりでいい
  def send_gadget_to_procon!
    monitor.record(:start_function)
    input = nil
    mutex.synchronize do
      begin
        next if $will_terminate_token
        # TODO blocking readにしたい
        input = self.gadget.read_nonblock(64)
        ProconBypassMan.logger.debug { ">>> #{input.unpack("H*")}" }
      rescue IO::EAGAINWaitReadable
        monitor.record(:eagain_wait_readable_on_read)
        sleep(0.005)
        retry
      end

      begin
        self.procon.write_nonblock(input)
      rescue IO::EAGAINWaitReadable
        monitor.record(:eagain_wait_readable_on_write)
        next
      rescue Errno::ETIMEDOUT => e
        # TODO まれにこれが発生する. 再接続したい
        ProconBypassMan.cache.fetch(key: 'send_gadget_to_procon', expires_in: 30) do
          ProconBypassMan::ErrorReporter.report(body: e)
          nil
        end
        raise
      end
    end
    sleep(0.005)

    monitor.record(:end_function)
  end

  def send_procon_to_gadget!
    monitor.record(:start_function)
    output = nil

    mutex.synchronize do
      begin
        next if $will_terminate_token
        Timeout.timeout(1) do
          output = self.procon.read(64)
          ProconBypassMan.logger.debug { "<<< #{output.unpack("H*")}" }
        end
      rescue Timeout::Error
        ProconBypassMan.logger.debug { "read timeout! do sleep. by send_procon_to_gadget!" }
        ProconBypassMan.error_logger.error { "read timeout! do sleep. by send_procon_to_gadget!" }
        monitor.record(:eagain_wait_readable_on_read)
        retry
      rescue IO::EAGAINWaitReadable
        ProconBypassMan.logger.debug { "EAGAINWaitReadable" }
        monitor.record(:eagain_wait_readable_on_read)
        sleep(0.005)
        retry
      end

      begin
        self.gadget.write_nonblock(ProconBypassMan::Processor.new(output).process)
      rescue IO::EAGAINWaitReadable
        monitor.record(:eagain_wait_readable_on_write)
        next
      end
    end
    monitor.record(:end_function)
  end
end
