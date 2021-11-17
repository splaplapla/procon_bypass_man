require "procon_bypass_man/outbound/http_client"
require "procon_bypass_man/outbound/jobs/base_event_job"

class ProconBypassMan::ErrorReporter < ProconBypassMan::BaseEventReporter
  # @param [String] body
  def self.report(body)
    ProconBypassMan::Outbound::HttpClient.new(
      path: path,
      server_picker: server_picker,
      retry_on_connection_error: false,
    ).post(body: body, event_type: :error,)
  end
end
