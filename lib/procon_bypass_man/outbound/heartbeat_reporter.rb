require "procon_bypass_man/outbound/http_client"
require "procon_bypass_man/outbound/base_event_reporter"

class ProconBypassMan::HeartbeatReporter < ProconBypassMan::BaseEventReporter
  def self.perform(body)
    ProconBypassMan::Outbound::HttpClient.new(
      path: path,
      server_picker: server_picker,
      retry_on_connection_error: false,
    ).post(body: body, event_type: :heartbeat)
  end
end
