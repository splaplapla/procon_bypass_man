class ProconBypassMan::Bypass
  module UsbHidLogger
    extend ProconBypassMan::Callbacks::ClassMethods
    include ProconBypassMan::Callbacks

    define_callbacks :send_gadget_to_procon
    define_callbacks :send_procon_to_gadget

    set_callback :send_gadget_to_procon, :after, :log_send_gadget_to_procon
    set_callback :send_procon_to_gadget, :after, :log_procon_to_gadget

    def log_send_gadget_to_procon
      ProconBypassMan.logger.debug { ">>> #{bypass_value.to_text}" }
    end

    def log_procon_to_gadget
      if ProconBypassMan.config.verbose_bypass_log
        ProconBypassMan.logger.debug { "<<< #{bypass_value.to_text}" }
      else
        ProconBypassMan.cache.fetch key: 'bypass_log', expires_in: 1 do
          ProconBypassMan.logger.debug { "<<< #{bypass_value.to_text}" }
        end
      end

      ProconBypassMan.cache.fetch key: 'pressed_buttons_reporter', expires_in: 5 do
        ProconBypassMan::PressedButtonsReporter.perform_async(
          ProconBypassMan::ProconReader.new(binary: bypass_value.binary).to_hash
        )
      end

      ProconBypassMan.cache.fetch key: 'heartbeat_reporter', expires_in: 60 do
        ProconBypassMan::HeartbeatReporter.perform_async(ProconBypassMan::BootMessage.new.to_hash)
      end
    end
  end
end
