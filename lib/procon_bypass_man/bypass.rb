require "procon_bypass_man/bypass/usb_hid_logger"
require "procon_bypass_man/bypass/bypass_command"
require "procon_bypass_man/bypass/concurrent_bypass_executor"

class ProconBypassMan::Bypass
  extend ProconBypassMan::CallbacksRegisterable

  register_callback_module(ProconBypassMan::Bypass::UsbHidLogger)
  register_callback_module(ProconBypassMan::ProconDisplay::BypassHook)

  class BypassValue < Struct.new(:binary)
    def to_text
      return unless binary
      binary.unpack.first
    end
  end

  attr_accessor :gadget, :procon, :bypass_value

  def initialize(gadget: , procon: )
    self.gadget = gadget
    self.procon = procon
  end

  # ゆっくりでいい
  def send_gadget_to_procon!
    self.bypass_value = BypassValue.new(nil)

    run_callbacks(:send_gadget_to_procon) do
      break if $will_terminate_token

      raw_input = nil
      begin
        raw_input = self.gadget.read_nonblock(64)
        self.bypass_value.binary = ProconBypassMan::Domains::InboundProconBinary.new(binary: raw_input)
      rescue IO::EAGAINWaitReadable
      end

      if self.bypass_value.binary
        begin
          raw_data =
            case
            when self.bypass_value.binary.rumble_data?
              binary = ProconBypassMan::RumbleBinary.new(binary: self.bypass_value.binary.raw)
              binary.noop!
              binary.raw
            else
              self.bypass_value.binary.raw
            end
          self.procon.write_nonblock(raw_data)
        rescue IO::EAGAINWaitReadable
          break
        end
      end
    end
  end

  def send_procon_to_gadget!
    ProconBypassMan::Procon::PerformanceMeasurement.measure do |measurement|
      self.bypass_value = BypassValue.new(nil)

      run_callbacks(:send_procon_to_gadget) do
        break if $will_terminate_token

        begin
          Timeout.timeout(0.1) do
            raw_output = self.procon.read(64)
            self.bypass_value.binary = ProconBypassMan::Domains::InboundProconBinary.new(binary: raw_output)
          end
        rescue Timeout::Error
          # TODO テストが通っていない
          ProconBypassMan::SendErrorCommand.execute(error: "read timeout! do sleep. by send_procon_to_gadget!")
          measurement.record_read_error
          retry
        end

        begin
          # TODO blocking writeにしたらどうなる？
          self.gadget.write_nonblock(
            ProconBypassMan::Processor.new(bypass_value.binary).process
          )
        rescue IO::EAGAINWaitReadable
          # TODO テストが通っていない
          measurement.record_write_error
        end
      end
    end
  end

  # @return [void]
  def direct_connect_switch_via_bluetooth
    ProconBypassMan.logger.debug { "direct_connect_switch_via_bluetooth!" }
    self.procon.write_nonblock(["010500000000000000003800"].pack("H*")) # home led off
    self.procon.write_nonblock(["010600000000000000003800"].pack("H*")) # home led off
    self.procon.write_nonblock(["010700000000000000003800"].pack("H*")) # home led off
    self.procon.write_nonblock(["010800000000000000003800"].pack("H*")) # home led off
    self.procon.write_nonblock(["8005"].pack("H*"))
    self.procon.write_nonblock(["8005"].pack("H*"))
    self.procon.write_nonblock(["8005"].pack("H*"))
  end
end
