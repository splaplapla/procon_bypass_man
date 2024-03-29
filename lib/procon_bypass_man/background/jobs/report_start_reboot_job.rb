class ProconBypassMan::ReportStartRebootJob < ProconBypassMan::ReportEventBaseJob
  extend ProconBypassMan::HasExternalApiSetting

  def self.perform
    ProconBypassMan::ReportHttpClient.new(
      path: path,
      server: api_server,
    ).post(body: nil, event_type: :start_reboot)
  end
end
