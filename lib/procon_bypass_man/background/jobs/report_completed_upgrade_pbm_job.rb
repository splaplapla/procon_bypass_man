class ProconBypassMan::ReportCompletedUpgradePbmJob < ProconBypassMan::ReportEventBaseJob
  extend ProconBypassMan::HasExternalApiSetting

  def self.perform
    ProconBypassMan::ReportHttpClient.new(
      path: path,
      server: api_server,
    ).post(body: nil, event_type: :completed_upgrade_pbm)
  end
end
