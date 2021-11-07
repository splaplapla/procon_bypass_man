require "procon_bypass_man/outbound/client"

class ProconBypassMan::Reporter
  extend ProconBypassMan::Outbound::HasServerPicker

  PATH = "/api/reports"

  def self.report(body: )
    ProconBypassMan::Outbound::Client.new(
      path: PATH,
      server_picker: server_picker,
      retry_on_connection_error: true,
    ).post(body: body)
  end

  def self.servers
    ProconBypassMan.config.api_servers
  end
end
