require "procon_bypass_man/bypass/bypass_command"

class ProconBypassMan::Bypass::ProconToSwitch
  extend ProconBypassMan::CallbacksRegisterable
  include ProconBypassMan::Callbacks

  class CouldNotReadFromProconError < StandardError; end
  class CouldNotWriteToSwitchError < StandardError; end

  define_callbacks :run
  set_callback :run, :after, :log_after_run

  register_callback_module(ProconBypassMan::ProconDisplay::BypassHook)

  attr_accessor :gadget, :procon, :bypass_value, :procon_binary_queue

  def initialize(gadget: , procon: )
    self.gadget = gadget
    self.procon = procon
  end

  # @raise [Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError, Errno::ESHUTDOWN, Errno::ETIMEDOUT]
  # @return [void]
  def run
    ProconBypassMan::Procon::PerformanceMeasurement.measure do |measurement|
      self.bypass_value = ProconBypassMan::Bypass::BypassValue.new(nil)

      next(run_callbacks(:run) {
        next(false) if $will_terminate_token

        raw_output = nil
        measurement.record_read_time do
          begin
            ProconBypassMan::GC.stop_gc_in do
              return(false) if $will_terminate_token
              raw_output = self.procon.read_nonblock(64)
            end
          rescue IO::EAGAINWaitReadable
            sleep(0.001)
            retry
          rescue Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError, Errno::ESHUTDOWN, Errno::ETIMEDOUT => e
            return(false) if $will_terminate_token
            raise
          end
        end

        self.bypass_value.binary = ProconBypassMan::Domains::InboundProconBinary.new(binary: raw_output)

        result = ProconBypassMan::GC.stop_gc_in do
          result = measurement.record_write_time do
            begin
              ProconBypassMan::Retryable.retryable(tries: 5, on_no_retry: [Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError, Errno::ESHUTDOWN, Errno::ETIMEDOUT]) do
                begin
                  # 終了処理を希望されているのでブロックを無視してメソッドを抜けてOK
                  return(false) if $will_terminate_token # rubocop:disable Lint/NoReturnInBeginEndBlocks
                  self.gadget.write_nonblock(
                    ProconBypassMan::Processor.new(bypass_value.binary).process
                  )
                  next(true)
                rescue IO::EAGAINWaitReadable
                  return(false) if $will_terminate_token # rubocop:disable Lint/NoReturnInBeginEndBlocks
                  measurement.record_write_error
                  raise CouldNotWriteToSwitchError
                rescue Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError, Errno::ESHUTDOWN, Errno::ETIMEDOUT => e
                  return(false) if $will_terminate_token # rubocop:disable Lint/NoReturnInBeginEndBlocks
                  raise
                end
              end
            rescue CouldNotWriteToSwitchError
              next(false)
            end
          end

          next(result)
        end

        next(result)
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

  private

  def log_after_run
    return unless bypass_value.to_text

    if ProconBypassMan.config.verbose_bypass_log
      ProconBypassMan.logger.debug { "<<< #{bypass_value.to_text}" }
    else
      ProconBypassMan.cache.fetch key: 'bypass_log', expires_in: 1 do
        ProconBypassMan.logger.debug { "<<< #{bypass_value.to_text}" }
      end
    end
  end
end
