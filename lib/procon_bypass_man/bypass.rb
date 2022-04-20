require "procon_bypass_man/bypass/usb_hid_logger"

class ProconBypassMan::Bypass
  include ProconBypassMan::Bypass::UsbHidLogger

  class BypassValue < Struct.new(:binary)
    def to_text
      return unless binary
      binary.unpack.first
    end
  end

  attr_accessor :gadget, :procon, :monitor, :bypass_value

  def initialize(gadget: , procon: , monitor: )
    self.gadget = gadget
    self.procon = procon
    self.monitor = monitor
  end

  # ゆっくりでいい
  def send_gadget_to_procon!
    monitor.record(:start_function)
    self.bypass_value = BypassValue.new(nil)

    run_callbacks(:send_gadget_to_procon) do
      break if $will_terminate_token

      raw_input = nil
      begin
        # TODO blocking readにしたいが、接続時のフェーズによって長さが違うので厳しい
        raw_input = self.gadget.read_nonblock(64)
        self.bypass_value.binary = ProconBypassMan::Domains::InboundProconBinary.new(binary: raw_input)
      rescue IO::EAGAINWaitReadable
        monitor.record(:eagain_wait_readable_on_read)
      end

      if raw_input
        begin
          self.procon.write_nonblock(raw_input)
        rescue IO::EAGAINWaitReadable
          monitor.record(:eagain_wait_readable_on_write)
          break
        end
      end
    end

    monitor.record(:end_function)
  end

  def send_procon_to_gadget!
    monitor.record(:start_function)
    self.bypass_value = BypassValue.new(nil)

    run_callbacks(:send_procon_to_gadget) do
      break if $will_terminate_token

      begin
        Timeout.timeout(1) do
          raw_output = self.procon.read(64)
          self.bypass_value.binary = ProconBypassMan::Domains::InboundProconBinary.new(binary: raw_output)
        end
      rescue Timeout::Error
        ProconBypassMan.logger.debug { "read timeout! do sleep. by send_procon_to_gadget!" }
        ProconBypassMan.error_logger.error { "read timeout! do sleep. by send_procon_to_gadget!" }
        ProconBypassMan::SendErrorCommand.execute(error: "read timeout! do sleep. by send_procon_to_gadget!")
        monitor.record(:eagain_wait_readable_on_read)
        retry
      rescue IO::EAGAINWaitReadable
        ProconBypassMan.logger.debug { "EAGAINWaitReadable" }
        monitor.record(:eagain_wait_readable_on_read)
        sleep(0.005)
        retry
      end

      begin
        self.gadget.write_nonblock(
          ProconBypassMan::Processor.new(bypass_value.binary).process
        )
      rescue IO::EAGAINWaitReadable
        monitor.record(:eagain_wait_readable_on_write)
        break
      end
    end
    monitor.record(:end_function)
  end

  # @return [void]
  def direct_connect_switch_via_bluetooth
    ProconBypassMan.logger.debug { "direct_connect_switch_via_bluetooth!" }
    self.procon.write_nonblock(["8005"].pack("H*"))
  end

  # @return [void] 入力してから取り出さないと接続しっぱなしになるっぽいのでこれが必要っぽい
  def be_empty_procon
    timer = ProconBypassMan::SafeTimeout.new(timeout: Time.now + 2)
    loop do
      break if timer.timeout?
      output = self.procon.read_nonblock(64)
      ProconBypassMan.logger.debug { "[ProconBypassMan::Bypass#be_empty_procon] #{output.unpack("H*").first}" }
    rescue IO::EAGAINWaitReadable
      # no-op
    end
  end
end
