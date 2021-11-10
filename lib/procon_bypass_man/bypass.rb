require "procon_bypass_man/bypass/usb_hid_logger"

class ProconBypassMan::Bypass
  include ProconBypassMan::Bypass::UsbHidLogger

  class BypassStatus < Struct.new(:binary, :sent)
    def to_text
      "#{binary.unpack("H*").first} #{'x' unless sent}"
    end
  end

  attr_accessor :gadget, :procon, :monitor, :bypass_status

  def initialize(gadget: , procon: , monitor: )
    self.gadget = gadget
    self.procon = procon
    self.monitor = monitor
  end

  # ゆっくりでいい
  def send_gadget_to_procon!
    monitor.record(:start_function)
    input = nil
    self.bypass_status = BypassStatus.new(input, sent = false)

    run_callbacks(:send_gadget_to_procon) do
      begin
        break if $will_terminate_token
        # TODO blocking readにしたいが、接続時のフェーズによって長さが違うので厳しい
        input = self.gadget.read_nonblock(64)
        self.bypass_status.binary = input
      rescue IO::EAGAINWaitReadable
        monitor.record(:eagain_wait_readable_on_read)
        sleep(0.001)
        retry
      end

      begin
        self.procon.write_nonblock(input)
        self.bypass_status.sent = true
      rescue IO::EAGAINWaitReadable
        monitor.record(:eagain_wait_readable_on_write)
        break
      end
    end

    monitor.record(:end_function)
  end

  def send_procon_to_gadget!
    monitor.record(:start_function)
    output = nil
    self.bypass_status = BypassStatus.new(output, sent = false)

    run_callbacks(:send_procon_to_gadget) do
      begin
        break if $will_terminate_token
        Timeout.timeout(1) do
          output = self.procon.read(64)
          self.bypass_status.binary = output
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
        self.bypass_status.sent = true
      rescue IO::EAGAINWaitReadable
        monitor.record(:eagain_wait_readable_on_write)
        break
      end
    end
    monitor.record(:end_function)
  end
end
