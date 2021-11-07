require "procon_bypass_man/outbound/client"

class ProconBypassMan::ErrorReporter
  extend ProconBypassMan::Outbound::HasServerPicker

  PATH = "/api/error_reports"

  def self.report(body: )
    ProconBypassMan::Outbound::Client.new(
      path: PATH,
      server_picker: server_picker,
    ).post(body: body.full_message)
  end

  def self.servers
    ProconBypassMan.config.api_servers
  end
end
