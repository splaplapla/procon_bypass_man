class ProconBypassMan::HeartbeatReporter < ProconBypassMan::BaseJob
  # @param [String] body
  def self.perform(body)
    ProconBypassMan::Background::HttpClient.new(
      path: path,
      server_picker: server_picker,
      retry_on_connection_error: false,
    ).post(body: body, event_type: :heartbeat)
  end
end
