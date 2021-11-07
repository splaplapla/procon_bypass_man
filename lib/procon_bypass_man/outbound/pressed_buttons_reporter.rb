require "procon_bypass_man/outbound/client"

class ProconBypassMan::PressedButtonsReporter
  PATH = "/api/pressed_buttons"

  def self.report(body: )
    ProconBypassMan::Outbound::Client.new(
      path: PATH,
      servers: ProconBypassMan.config.internal_api_servers,
    ).post(body: body)
  end
end

