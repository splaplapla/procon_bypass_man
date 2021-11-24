class ProconBypassMan::PoolingCommandJob < ProconBypassMan::BaseJob
  extend ProconBypassMan::HasExternalApiSetting

  def self.perform
    ProconBypassMan::HttpClient.new()
  end
end
