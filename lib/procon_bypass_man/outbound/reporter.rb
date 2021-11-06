require "procon_bypass_man/outbound/base"

class ProconBypassMan::Reporter < ProconBypassMan::Outbound::Base
  PATH = "/api/reports"

  def self.report(body: )
    Client.new(
      path: PATH,
      servers: ProconBypassMan.config.api_servers,
    ).post(body: body)
  end
end
