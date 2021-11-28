class ProconBypassMan::SyncDeviceStatsJob < ProconBypassMan::BaseJob
  extend ProconBypassMan::HasExternalApiSetting

  # @param [Symbol] status
  def self.perform(status)
    ProconBypassMan::SendDeviceStatsHttpClient.new(
      path: path,
      server_pool: server_pool,
    ).post(status: status)
  end

  def self.path
    device_id = ProconBypassMan.device_id
    "/api/devices/#{ProconBypassMan.device_id}/device_statuses"
  end
end
