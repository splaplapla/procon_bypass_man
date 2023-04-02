# frozen_string_literal: true

require "procon_bypass_man/bypass/bypass_command"

class ProconBypassMan::Bypass::ProconToSwitch
  extend ProconBypassMan::CallbacksRegisterable
  include ProconBypassMan::Callbacks

  class CouldNotReadFromProconError < StandardError; end
  class CouldNotWriteToSwitchError < StandardError; end

  define_callbacks :work
  set_callback :work, :after, :log_after_run

  # マルチプロセス化したので一旦無効にする
  # register_callback_module(ProconBypassMan::ProconDisplay::BypassHook)

  attr_accessor :gadget, :procon, :bypass_value

  def initialize(gadget: , procon: )
    self.gadget = gadget
    self.procon = procon
  end

  # @raise [Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError, Errno::ESHUTDOWN, Errno::ETIMEDOUT]
  # @return [void]
  def work(*)
    ProconBypassMan::Procon::PerformanceMeasurement.measure do |measurement|
      self.bypass_value = ProconBypassMan::Bypass::BypassValue.new(nil)

      next(run_callbacks(:work) {
        next(false) if will_terminate?

        raw_output = nil
        measurement.record_read_time do
          begin
            return(false) if will_terminate?
            raw_output = self.procon.read_nonblock(64)
          rescue IO::EAGAINWaitReadable
            sleep(0.002)
            retry
          rescue Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError, Errno::ESHUTDOWN, Errno::ETIMEDOUT => e
            return(false) if will_terminate?
            raise
          end

          self.bypass_value.binary = ProconBypassMan::Domains::InboundProconBinary.new(binary: raw_output)
        end

        # 後続処理で入力値を取得できるように詰めておく
        ProconBypassMan::ProconDisplay::Status.instance.current = bypass_value.binary.to_procon_reader.to_hash

        result = measurement.record_write_time do
          begin
            ProconBypassMan::Retryable.retryable(tries: 5, on_no_retry: [Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError, Errno::ESHUTDOWN, Errno::ETIMEDOUT]) do
              # NOTE: 外部からの入力を受け取る
              # TODO: measurement.record_read_external_input_time doみたいに測定できるようにする
              external_input_data = nil
              if(data = ProconBypassMan::ExternalInput.read)
                begin
                  external_input_data = ProconBypassMan::ExternalInput::ExternalData.parse!(data)
                  ProconBypassMan.logger.debug { "[ExternalInput] 読み取った値: { hex: #{external_input_data.hex}, buttons: #{external_input_data.buttons} }" }
                rescue ProconBypassMan::ExternalInput::ParseError => e
                  ProconBypassMan.logger.error "[ExternalInput][#{e}] #{data} をparseできませんでした"
                end
              end

              begin
                # 終了処理を希望されているのでブロックを無視してメソッドを抜けてOK
                return(false) if will_terminate? # rubocop:disable Lint/NoReturnInBeginEndBlocks

                binary = ::ProconBypassMan::Procon::Rumbler.monitor do
                  ProconBypassMan::Processor.new(bypass_value.binary).process(external_input_data: external_input_data)
                end
                self.gadget.write_nonblock(binary)

                if ProconBypassMan.ephemeral_config.enable_rumble_on_layer_change && ProconBypassMan::Procon::Rumbler.must_rumble?
                  begin
                    self.procon.write_nonblock(ProconBypassMan::Procon::Rumbler.binary)
                    ProconBypassMan.logger.debug { ProconBypassMan::Procon::Rumbler.binary.unpack('H*').first }
                  rescue => e
                    ProconBypassMan::SendErrorCommand.execute(error: e)
                  end
                end

                next(true)
              rescue IO::EAGAINWaitReadable
                return(false) if will_terminate? # rubocop:disable Lint/NoReturnInBeginEndBlocks
                measurement.record_write_error
                raise CouldNotWriteToSwitchError
              rescue Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError, Errno::ESHUTDOWN, Errno::ETIMEDOUT => e
                return(false) if will_terminate? # rubocop:disable Lint/NoReturnInBeginEndBlocks
                raise
              end
            end
          rescue CouldNotWriteToSwitchError
            next(false)
          end
        end

        next(result)
      })
    end
  end

  # @return [void]
  def direct_connect_switch_via_bluetooth
    ProconBypassMan.logger.debug { "[BYPASS] プロコンとSwitchを無線接続へ切り替えます" }
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
    return unless ProconBypassMan.config.verbose_bypass_log
    return unless bypass_value.to_text

    ProconBypassMan.logger.debug { "<<< #{bypass_value.to_text}" }
  end

  # @return [Boolean]
  def will_terminate?
    $will_terminate_token
  end
end
