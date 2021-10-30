class ProconBypassMan::Bypass
  module UsbHidLogger
    extend ProconBypassMan::Callbacks::ClassMethods
    include ProconBypassMan::Callbacks

    define_callbacks :send_gadget_to_procon
    define_callbacks :send_procon_to_gadget

    set_callback :send_gadget_to_procon, :after, :log_send_gadget_to_procon
    set_callback :send_procon_to_gadget, :after, :log_procon_to_gadget

    def log_send_gadget_to_procon
      ProconBypassMan.logger.debug { ">>> #{bypass_status.to_text}" }
    end

    def log_procon_to_gadget
      ProconBypassMan.logger.debug { "<<< #{bypass_status.to_text}" }

      ProconBypassMan.cache.fetch key: 'reporter', expires_in: 5 do
        # TODO Button's hashを送る
        ProconBypassMan::Background::Reporter.queue.push({
          data: ProconBypassMan::ReadonlyProcon.new(binary: bypass_status.binary).to_hash,
          reporter_class: ProconBypassMan::PressedButtonsReporter
        })
      end
    end
  end
end
