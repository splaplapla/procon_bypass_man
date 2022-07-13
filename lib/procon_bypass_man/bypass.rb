require "procon_bypass_man/bypass/usb_hid_logger"
require "procon_bypass_man/bypass/bypass_command"

# TODO switch => procon,  procon => procon でクラスを分離する
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

  attr_accessor :gadget, :procon, :bypass_value, :procon_binary_queue

  def initialize(gadget: , procon: , flag: false)
    self.gadget = gadget
    self.procon = procon
    self.procon_binary_queue = Queue.new
    start_procon_binary_thread(procon: procon, queue: procon_binary_queue) if flag
  end

  # ゆっくりでいい
  def send_gadget_to_procon
    self.bypass_value = BypassValue.new(nil)

    run_callbacks(:send_gadget_to_procon) do
      next if $will_terminate_token

      raw_input = nil
      begin
        raw_input = self.gadget.read_nonblock(64)
        self.bypass_value.binary = ProconBypassMan::Domains::InboundProconBinary.new(binary: raw_input)
      rescue IO::EAGAINWaitReadable
        next
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
          next
        end
      end
    end
  end

  def start_procon_binary_thread(procon: , queue: )
    Thread.new do
      loop do
        begin
          raw_binady = nil
          Timeout.timeout(1.0) do
            raw_binady = procon.read(64)
          end
          # 空の時にのみ追加する
          queue.push(raw_binady) if queue.empty?
        rescue Timeout::Error # TODO テストが通っていない
          # no-op
          ProconBypassMan.logger.debug { "Timeout at dstart_procon_binary_thread!" }
        end
      end
    end
  end

  def send_procon_to_gadget
    ProconBypassMan::Procon::PerformanceMeasurement.measure do |measurement|
      self.bypass_value = BypassValue.new(nil)

      next(run_callbacks(:send_procon_to_gadget) {
        next(false) if $will_terminate_token

        raw_output = procon_binary_queue.pop
        self.bypass_value.binary = ProconBypassMan::Domains::InboundProconBinary.new(binary: raw_output)

        begin
          self.gadget.write_nonblock(
            ProconBypassMan::Processor.new(bypass_value.binary).process
          )
        rescue IO::EAGAINWaitReadable # TODO テストが通っていない
          measurement.record_write_error
          next(false) # retryでもいい気がする
        end

        next(true)
      })
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
