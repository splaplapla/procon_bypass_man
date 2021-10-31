require "procon_bypass_man/outbound/base"

class ProconBypassMan::Reporter < ProconBypassMan::Outbound::Base
  PATH = "/api/reports"

  def self.report(body: )
    Client.new(
      path: PATH,
      server: ProconBypassMan.config.api_server,
    ).post(body: body)
  end
end
