class ProconBypassMan::SyncDeviceStatsJob
  extend ProconBypassMan::HasExternalApiSetting

  # @param [Symbol] stats
  def self.perform(stats)
    ProconBypassMan::SendDeviceStatsHttpClient.new(
      path: path,
      server_pool: server_pool,
    ).post(stats: stats)
  end

  def self.path
    device_id = ProconBypassMan.device_id
    "/api/devices/#{ProconBypassMan.device_id}/device_statuses"
  end
end
