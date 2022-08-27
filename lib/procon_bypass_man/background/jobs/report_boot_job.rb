class ProconBypassMan::ReportBootJob < ProconBypassMan::ReportEventBaseJob
  extend ProconBypassMan::HasExternalApiSetting

  # @param [String] body
  def self.perform(body)
    ProconBypassMan::ReportHttpClient.new(
      path: path,
      server: api_server,
      retry_on_connection_error: true,
    ).post(body: body, event_type: :boot)
  end
end
