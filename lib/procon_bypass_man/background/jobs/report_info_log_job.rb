class ProconBypassMan::ReportInfoLogJob < ProconBypassMan::ReportEventBaseJob
  extend ProconBypassMan::HasExternalApiSetting

  # @param [String] body
  def self.perform(body)
    ProconBypassMan::ReportHttpClient.new(
      path: path,
      server: api_server,
    ).post(body: body, event_type: :info)
  end
end
