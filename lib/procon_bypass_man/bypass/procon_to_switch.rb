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
    self.procon_binary_queue = Queue.new
    start_procon_binary_thread(procon: procon, queue: self.procon_binary_queue)
  end

  def run
    ProconBypassMan::Procon::PerformanceMeasurement.measure do |measurement|
      self.bypass_value = ProconBypassMan::Bypass::BypassValue.new(nil)

      next(run_callbacks(:run) {
        next(false) if $will_terminate_token

        raw_output = nil
        measurement.record_read_time do
          raw_output = self.procon_binary_queue.shift
        end
        self.bypass_value.binary = ProconBypassMan::Domains::InboundProconBinary.new(binary: raw_output)

        measurement.record_write_time do
          begin
            self.gadget.write_nonblock(
              ProconBypassMan::Processor.new(bypass_value.binary).process
            )
          rescue IO::EAGAINWaitReadable # TODO テストが通っていない
            measurement.record_write_error
            # next(false) # retryでもいい気がする
            retry
          end
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

  private

  def start_procon_binary_thread(procon: , queue: )
    buffer_size = 10
    throttling = ProconBypassMan::Bypass::ProconReadThrottling.new

    Thread.new do
      loop do
        begin
          raw_binary = nil
          Timeout.timeout(1.0) do
            throttling.run do
              raw_binary = procon.read(64)
            end
          end

          queue.push(raw_binary)
          queue.shift if queue.size > buffer_size # 古い入力が溜まったら古いものから捨てる

        rescue Timeout::Error # TODO テストが通っていない
          ProconBypassMan::SendErrorCommand.execute(error: "プロコンからの読み取りがタイムアウトになりました")
        end
      end
    end
  end

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
