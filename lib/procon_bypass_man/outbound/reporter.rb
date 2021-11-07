require "procon_bypass_man/outbound/client"

class ProconBypassMan::Reporter
  extend ProconBypassMan::Outbound::HasServerPicker

  PATH = "/api/reports"

  def self.report(body: )
    ProconBypassMan::Outbound::Client.new(
      path: PATH,
      server_picker: server_picker,
    ).post(body: body)
  end

  def self.servers
    ProconBypassMan.config.api_servers
  end
end
