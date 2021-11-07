require "procon_bypass_man/outbound/client"

class ProconBypassMan::ErrorReporter
  PATH = "/api/error_reports"

  def self.report(body: )
    ProconBypassMan::Outbound::Client.new(
      path: PATH,
      servers: ProconBypassMan.config.api_servers,
    ).post(body: body.full_message)
  end
end

