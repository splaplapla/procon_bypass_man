class ProconBypassMan::Bypass
  attr_accessor :gadget, :procon, :monitor
  def initialize(gadget: , procon: , monitor: )
    self.gadget = gadget
    self.procon = procon
    self.monitor = monitor
  end

  # ゆっくりでいい
  def send_gadget_to_procon!
    monitor.record(:start_function)
    input = nil
    begin
      sleep($will_interval_1_6)
      input = self.gadget.read_nonblock(128)
      ProconBypassMan.logger.debug { ">>> #{input.unpack("H*")}" }
    rescue IO::EAGAINWaitReadable
      monitor.record(:eagain_wait_readable_on_read)
      return if $will_terminate_token
      retry
    end

    begin
      self.procon.write_nonblock(input)
    rescue IO::EAGAINWaitReadable
      monitor.record(:eagain_wait_readable_on_write)
      return
    end
    monitor.record(:end_function)
  end

  def send_procon_to_gadget!
    monitor.record(:start_function)
    output = nil
    begin
      return if $will_terminate_token
      Timeout.timeout(1) do
        output = self.procon.read(128)
        ProconBypassMan.logger.debug { "<<< #{output.unpack("H*")}" }
      end
    rescue Timeout::Error
      ProconBypassMan.logger.debug { "read timeout sleep" }
      monitor.record(:eagain_wait_readable_on_read)
      retry
    rescue IO::EAGAINWaitReadable
      ProconBypassMan.logger.debug { "EAGAINWaitReadable" }
      monitor.record(:eagain_wait_readable_on_read)
      sleep($will_interval_0_0_0_5)
      retry
    end

    begin
      self.gadget.write_nonblock(ProconBypassMan::Processor.new(output).process)
    rescue IO::EAGAINWaitReadable
      monitor.record(:eagain_wait_readable_on_write)
      return
    end
    monitor.record(:end_function)
  end
end
