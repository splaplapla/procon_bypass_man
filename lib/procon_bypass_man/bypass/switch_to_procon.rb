# frozen_string_literal: true

require "procon_bypass_man/bypass/bypass_command"

class ProconBypassMan::Bypass::SwitchToProcon
  include ProconBypassMan::Callbacks

  define_callbacks :run
  set_callback :run, :after, :log_after_run

  attr_accessor :gadget, :procon, :bypass_value

  def initialize(gadget: , procon: )
    self.gadget = gadget
    self.procon = procon
  end

  # ゆっくりでいい
  def run
    self.bypass_value = ProconBypassMan::Bypass::BypassValue.new(nil)

    run_callbacks(:run) do
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
            when self.bypass_value.binary.rumble_data? # TODO そもそも無効になっているので消していい
              binary = ProconBypassMan::RumbleBinary.new(binary: self.bypass_value.binary.raw)
              binary.noop!
              binary.raw
            else
              self.bypass_value.binary.raw
            end
          # バイブレーションを無効にしているのでおそらく書き込む必要はない
          # self.procon.write_nonblock(raw_data)
        rescue IO::EAGAINWaitReadable
          next
        end
      end
    end
  end

  private

  def log_after_run
    return unless bypass_value.to_text

    if ProconBypassMan.config.verbose_bypass_log
      ProconBypassMan.logger.debug { ">>> #{bypass_value.to_text}" }
    else
      ProconBypassMan.cache.fetch key: 'bypass_log', expires_in: 1 do
        ProconBypassMan.logger.debug { ">>> #{bypass_value.to_text}" }
      end
    end
  end
end
