require "procon_bypass_man/outbound/http_client"

class ProconBypassMan::HeartbeatReporter < ProconBypassMan::BaseEventReporter
  # @param [String] body
  def self.perform(body)
    ProconBypassMan::Outbound::HttpClient.new(
      path: path,
      server_picker: server_picker,
      retry_on_connection_error: false,
    ).post(body: body, event_type: :heartbeat)
  end
end
