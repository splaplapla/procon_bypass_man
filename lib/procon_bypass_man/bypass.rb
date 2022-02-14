require "procon_bypass_man/bypass/usb_hid_logger"
require "procon_bypass_man/bypass/bypass_mode"

class ProconBypassMan::Bypass
  include ProconBypassMan::Bypass::UsbHidLogger

  class BypassValue < Struct.new(:binary, :sent)
    def to_text
      return unless binary
      "#{binary.unpack.first} #{'x' unless sent}"
    end
  end

  attr_accessor :gadget, :procon, :monitor, :bypass_value

  def initialize(gadget: , procon: , monitor: )
    self.gadget = gadget
    self.procon = procon
    self.monitor = monitor
  end

  def disconnect_procon!
    %w(
      01040001404000014040300000000000000000000000000000000000000000000000000000000000000000000000000000
      010d0000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000
      01020001404000014040300000000000000000000000000000000000000000000000000000000000000000000000000000
      01070000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000
    ).each { |d| self.procon.write_nonblock([d].pack("H*")) }
  end

  # ゆっくりでいい
  def send_gadget_to_procon!
    monitor.record(:start_function)
    input = nil
    self.bypass_value = BypassValue.new(nil, sent = false)

    run_callbacks(:send_gadget_to_procon) do
      break if $will_terminate_token

      begin
        # TODO blocking readにしたいが、接続時のフェーズによって長さが違うので厳しい
        input = self.gadget.read_nonblock(64)
        self.bypass_value.binary = ProconBypassMan::Domains::InboundProconBinary.new(binary: input)
      rescue IO::EAGAINWaitReadable
        monitor.record(:eagain_wait_readable_on_read)
      end

      if input
        begin
          self.procon.write_nonblock(input)
          self.bypass_value.sent = true
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
    output = nil
    self.bypass_value = BypassValue.new(nil, sent = false)

    run_callbacks(:send_procon_to_gadget) do
      begin
        break if $will_terminate_token
        Timeout.timeout(1) do
          output = self.procon.read(64)
          self.bypass_value.binary = ProconBypassMan::Domains::InboundProconBinary.new(binary: output)
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

      # blocking readをしているのでnilが入ることはないが、雑なテストでnilが通るので分岐を入れる。できれば消したい
      break if output.nil?

      begin
        self.gadget.write_nonblock(
          ProconBypassMan::Processor.new(
            ProconBypassMan::Domains::InboundProconBinary.new(binary: output)
          ).process
        )
        self.bypass_value.sent = true
      rescue IO::EAGAINWaitReadable
        monitor.record(:eagain_wait_readable_on_write)
        break
      end
    end
    monitor.record(:end_function)
  end
end
