require "procon_bypass_man/outbound/client"

class ProconBypassMan::Reporter
  PATH = "/api/reports"

  def self.report(body: )
    ProconBypassMan::Outbound::Client.new(
      path: PATH,
      servers: ProconBypassMan.config.api_servers,
    ).post(body: body)
  end
end
