require "procon_bypass_man/outbound/base"

class ProconBypassMan::ErrorReporter < ProconBypassMan::Outbound::Base
  PATH = "/api/error_reports"

  def self.report(body: )
    Client.new(
      path: PATH,
      server: ProconBypassMan.config.api_server,
    ).post(body: body.full_message.to_json)
  end
end
