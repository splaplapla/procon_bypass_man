class ProconBypassMan::ReportReloadConfigJob < ProconBypassMan::ReportEventBaseJob
  extend ProconBypassMan::HasExternalApiSetting

  # @param [String] body
  def self.perform(body)
    ProconBypassMan::ReportHttpClient.new(
      path: path,
      server: api_server,
    ).post(body: body, event_type: :reload_config)
  end
end
