class ProconBypassMan::ErrorReporter < ProconBypassMan::BaseJob
  # @param [String] body
  def self.report(body)
    ProconBypassMan::Background::HttpClient.new(
      path: path,
      server_picker: server_picker,
      retry_on_connection_error: false,
    ).post(body: body, event_type: :error,)
  end
end
