class ProconBypassMan::Bypass
  attr_accessor :gadget, :procon, :monitor
  def initialize(gadget: , procon: , monitor: )
    self.gadget = gadget
    self.procon = procon
    self.monitor = monitor
  end

  def send_gadget_to_procon!
    monitor.record(:start_function)
    begin
      monitor.record(:before_read)
      input = self.gadget.read_nonblock(128)
      monitor.record(:after_read)
    #rescue IO::EAGAINWaitReadable
    #  monitor.record(:eagain_wait_readable_on_read)
    #  retry
    #end

    begin
      monitor.record(:before_write)
      self.procon.write_nonblock(input)
      monitor.record(:after_write)
      sleep($will_interval_1_6)
    rescue IO::EAGAINWaitReadable
      monitor.record(:eagain_wait_readable_on_write)
      sleep($will_interval_1_6)
      return
    end
    monitor.record(:end_function)
  end

  def send_procon_to_gadget!
    monitor.record(:start_function)
    output = nil
    begin
      monitor.record(:before_read)
      output = @procon.read_nonblock(128)
      monitor.record(:after_read)
    rescue IO::EAGAINWaitReadable
      monitor.record(:eagain_wait_readable_on_read)
      retry
    end

    begin
      ProconBypassMan.logger.debug { "<<< #{output.unpack("H*")}" }
      monitor.record(:before_write)
      self.gadget.write_nonblock(ProconBypassMan::Processor.new(output).process)
      monitor.record(:after_write)
      sleep($will_interval_0_0_1)
    rescue IO::EAGAINWaitReadable
      monitor.record(:eagain_wait_readable_on_write)
      return
    end
    monitor.record(:end_function)
  end
end
