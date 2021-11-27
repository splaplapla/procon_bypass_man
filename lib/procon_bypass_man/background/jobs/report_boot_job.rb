class ProconBypassMan::ReportBootJob < ProconBypassMan::ReportBaseJob
  extend ProconBypassMan::HasExternalApiSetting

  # @param [String] body
  def self.perform(body)
    ProconBypassMan::ReportHttpClient.new(
      path: path,
      server_pool: server_pool,
      retry_on_connection_error: true,
    ).post(body: body, event_type: :boot)
  end
end
