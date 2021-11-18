class ProconBypassMan::ReportReloadConfigJob <  ProconBypassMan::BaseJob
  # @param [String] body
  def self.perform(body)
    ProconBypassMan::Background::HttpClient.new(
      path: path,
      pool_server: pool_server,
      retry_on_connection_error: false,
    ).post(body: body, event_type: :boot)
  end
end