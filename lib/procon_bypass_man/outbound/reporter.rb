require "procon_bypass_man/outbound/client"

class ProconBypassMan::Reporter
  PATH = "/api/reports"

  def self.report(body: )
    ProconBypassMan::Outbound::Client.new(
      path: PATH,
      server_picker: server_picker,
    ).post(body: body)
  end

  def self.server_picker
    @@server_picker ||= ProconBypassMan::Outbound::ServersPicker.new(
      servers: ProconBypassMan.config.api_servers
    )
  end

  def self.reset!
    @@server_picker = nil
  end
end
