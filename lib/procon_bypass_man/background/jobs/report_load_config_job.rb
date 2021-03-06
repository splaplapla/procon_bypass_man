class ProconBypassMan::ReportLoadConfigJob < ProconBypassMan::ReportEventBaseJob
  extend ProconBypassMan::HasExternalApiSetting

  # @param [String] body
  def self.perform(body)
    ProconBypassMan::ReportHttpClient.new(
      path: path,
      server_pool: server_pool,
    ).post(body: body, event_type: :load_config)
  end
end
