class ProconBypassMan::Bypass
  attr_accessor :gadget, :procon, :monitor
  def initialize(gadget: , procon: , monitor: )
    self.gadget = gadget
    self.procon = procon
    self.monitor = monitor
  end

  @@connected = false
  def send_gadget_to_procon!(queue: nil)
    monitor.record(:start_function)
    begin
      input = self.gadget.read_nonblock(128)
      ProconBypassMan.logger.debug { ">>> #{input.unpack("H*")}" }
      #rescue IO::EAGAINWaitReadable
      #  monitor.record(:eagain_wait_readable_on_read)
      #  return if $will_terminate_token
      #  retry
      #end

      # これが返ってきたら接続完了とみなす
      if (input[0] == "\x10".b) && (input.size == 10) && queue && !@@connected
        queue.push(true)
        @@connected = true
      end

      self.procon.write_nonblock(input)
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
      sleep($will_interval_0_0_1)
      output = self.procon.read_nonblock(128)
    rescue IO::EAGAINWaitReadable
      monitor.record(:eagain_wait_readable_on_read)
      return if $will_terminate_token
      retry
    end

    begin
      ProconBypassMan.logger.debug { "<<< #{output.unpack("H*")}" }
      self.gadget.write_nonblock(ProconBypassMan::Processor.new(output).process)
    rescue IO::EAGAINWaitReadable
      monitor.record(:eagain_wait_readable_on_write)
      return
    end
    monitor.record(:end_function)
  end
end
