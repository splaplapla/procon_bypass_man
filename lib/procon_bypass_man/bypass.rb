class ProconBypassMan::Bypass
  attr_accessor :gadget, :procon, :monitor
  def initialize(gadget: , procon: , monitor: )
    self.gadget = gadget
    self.procon = procon
    self.monitor = monitor
  end

  def send_gadget_to_procon!
    begin
      input = self.gadget.read_nonblock(128)
      self.procon.write_nonblock(input)
      sleep($will_interval_1_6)
    rescue IO::EAGAINWaitReadable
      sleep($will_interval_1_6)
      return
    end
  end

  def send_procon_to_gadget!
    output = nil
    begin
      output = self.procon.read_nonblock(128)
    rescue IO::EAGAINWaitReadable
      retry
    end

    begin
      ProconBypassMan.logger.debug { "<<< #{output.unpack("H*")}" }
      self.gadget.write_nonblock(ProconBypassMan::Processor.new(output).process)
      sleep($will_interval_0_0_1)
    rescue IO::EAGAINWaitReadable
      return
    end
  end
end
