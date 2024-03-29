class ProconBypassMan::SyncDeviceStatsJob < ProconBypassMan::BaseJob
  extend ProconBypassMan::HasExternalApiSetting

  # @param [Symbol] status
  def self.perform(status)
    ProconBypassMan::SendDeviceStatsHttpClient.new(
      path: path,
      server: api_server,
    ).post(status: status, pbm_session_id: ProconBypassMan.session_id)
  end

  def self.path
    device_id = ProconBypassMan.device_id
    "/api/devices/#{ProconBypassMan.device_id}/device_statuses"
  end
end
