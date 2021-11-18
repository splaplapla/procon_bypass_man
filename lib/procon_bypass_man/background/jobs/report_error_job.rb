class ProconBypassMan::ReportErrorJob < ProconBypassMan::BaseJob
  # @param [String] body
  def self.report(body)
    ProconBypassMan::Background::HttpClient.new(
      path: path,
      pool_server: pool_server,
      retry_on_connection_error: false,
    ).post(body: body, event_type: :error,)
  end
end
