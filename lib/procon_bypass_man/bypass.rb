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
    sent = false
    begin
      return if $will_terminate_token
      # TODO blocking readにしたい
      input = self.gadget.read_nonblock(64)
    rescue IO::EAGAINWaitReadable
      monitor.record(:eagain_wait_readable_on_read)
      sleep(0.001)
      retry
    end

    begin
      self.procon.write_nonblock(input)
      sent = true
    rescue IO::EAGAINWaitReadable
      monitor.record(:eagain_wait_readable_on_write)
      return
    ensure
      ProconBypassMan.logger.debug { ">>> #{input.unpack("H*")} #{'x' unless sent}" }
    end

    monitor.record(:end_function)
  end

  def send_procon_to_gadget!
    monitor.record(:start_function)
    output = nil
    sent = false

    begin
      return if $will_terminate_token
      Timeout.timeout(1) do
        output = self.procon.read(64)
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
      # ProconBypassMan::Procon::DebugDumper.new(binary: output).dump_analog_sticks
      self.gadget.write_nonblock(ProconBypassMan::Processor.new(output).process)
      sent = true
    rescue IO::EAGAINWaitReadable
      monitor.record(:eagain_wait_readable_on_write)
      return
    ensure
      ProconBypassMan.logger.debug { "<<< #{output.unpack("H*")} #{'x' unless sent}" }
    end
    monitor.record(:end_function)
  end
end
