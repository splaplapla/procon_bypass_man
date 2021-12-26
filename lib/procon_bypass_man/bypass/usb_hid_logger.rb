class ProconBypassMan::Bypass
  module UsbHidLogger
    extend ProconBypassMan::Callbacks::ClassMethods
    include ProconBypassMan::Callbacks

    define_callbacks :send_gadget_to_procon
    define_callbacks :send_procon_to_gadget

    set_callback :send_gadget_to_procon, :after, :log_send_gadget_to_procon
    set_callback :send_procon_to_gadget, :after, :log_procon_to_gadget

    def log_send_gadget_to_procon
      if ProconBypassMan.config.verbose_bypass_log
        ProconBypassMan.logger.debug { ">>> #{bypass_value.to_text}" }
      else
        ProconBypassMan.cache.fetch key: 'bypass_log', expires_in: 1 do
          ProconBypassMan.logger.debug { ">>> #{bypass_value.to_text}" }
        end
      end
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
        ProconBypassMan::ReportPressedButtonsJob.perform_async(
          bypass_value.binary.to_procon_reader.to_hash
        )
      end
    end
  end
end
