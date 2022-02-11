class ProconBypassMan::ReportStartRebootJob < ProconBypassMan::ReportEventBaseJob
  extend ProconBypassMan::HasExternalApiSetting

  def self.perform
    ProconBypassMan::ReportHttpClient.new(
      path: path,
      server_pool: server_pool,
    ).post(body: nil, event_type: :start_reboot)
  end
end
