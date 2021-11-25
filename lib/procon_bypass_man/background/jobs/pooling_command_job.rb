class ProconBypassMan::PoolingCommandJob < ProconBypassMan::BaseJob
  extend ProconBypassMan::HasExternalApiSetting

  def self.perform
    response = ProconBypassMan::HttpClient.new(
      path: path,
      pool_server: pool_server,
    ).get
  end

  def self.path
    device_id = ENV["DEBUG_DEVICE_ID"] || ProconBypassMan.device_id
    "/api/devices/#{device_id}/pbm_jobs"
  end
end
