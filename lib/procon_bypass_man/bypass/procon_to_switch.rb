require "procon_bypass_man/bypass/bypass_command"

class ProconBypassMan::Bypass::ProconToSwitch
  extend ProconBypassMan::CallbacksRegisterable
  include ProconBypassMan::Callbacks

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
        retry_count = 0
        ProconBypassMan::GC.stop_gc_in do
          measurement.record_read_time do
            begin
              Timeout.timeout(1.0) do
                raw_output = procon.read(64)
              end
            rescue Timeout::Error # TODO テストが通っていない
              ProconBypassMan::SendErrorCommand.execute(error: "プロコンからの読み取りがタイムアウトになりました")
              next(false)  if $will_terminate_token

              if 5 > retry_count
                retry_count =  retry_count + 1
                retry
              else
                next(false)
              end
            rescue Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError, Errno::ESHUTDOWN, Errno::ETIMEDOUT => e
              raise
            end
          end
        end

        self.bypass_value.binary = ProconBypassMan::Domains::InboundProconBinary.new(binary: raw_output)

        retry_count = 0
        result = ProconBypassMan::GC.stop_gc_in do
          result = measurement.record_write_time do
            begin
              self.gadget.write_nonblock(
                ProconBypassMan::Processor.new(bypass_value.binary).process
              )
              next(true)
            rescue IO::EAGAINWaitReadable
              measurement.record_write_error
              next(false) if $will_terminate_token

              if 5 > retry_count
                retry_count =  retry_count + 1
                retry
              else
                next(false)
              end
            rescue Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError, Errno::ESHUTDOWN, Errno::ETIMEDOUT => e
              raise
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

    if ProconBypassMan.config.enable_reporting_pressed_buttons
      ProconBypassMan.cache.fetch key: 'pressed_buttons_reporter', expires_in: 5 do
        ProconBypassMan::ReportPressedButtonsJob.perform_async(
          bypass_value.binary.to_procon_reader.to_hash
        )
      end
    end
  end
end
