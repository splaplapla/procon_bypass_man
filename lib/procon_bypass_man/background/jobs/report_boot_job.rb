class ProconBypassMan::ReportBootJob <  ProconBypassMan::BaseJob
  # @param [String] body
  def self.perform(body)
    ProconBypassMan::Background::HttpClient.new(
      path: path,
      server_picker: server_picker,
      retry_on_connection_error: true,
    ).post(body: body, event_type: :boot)
  end
end
