require "procon_bypass_man/outbound/http_client"

class ProconBypassMan::PressedButtonsReporter
  extend ProconBypassMan::Outbound::HasRoundRobinServer
  extend ProconBypassMan::Outbound::JobRunnable

  PATH = "/api/pressed_buttons"

  # @param [String] body
  def self.perform(body)
    ProconBypassMan::Outbound::HttpClient.new(
      path: PATH,
      server_picker: server_picker,
    ).post(body: body, event_type: :internal)
  end

  def self.servers
    ProconBypassMan.config.internal_api_servers
  end
end
