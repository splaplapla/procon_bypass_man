class ProconBypassMan::SyncDeviceStatsJob
  extend ProconBypassMan::HasExternalApiSetting

  # @param [Symbol] stats
  def self.perform(stats)
    ProconBypassMan::SendDeviceStatsHttpClient.new(
      path: path,
      server_pool: server_pool,
    ).post(body: {}, stats: stats)
  end
end
