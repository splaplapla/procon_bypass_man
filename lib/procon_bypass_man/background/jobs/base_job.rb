class ProconBypassMan::BaseJob
  extend ProconBypassMan::Background::HasRoundRobinServer
  extend ProconBypassMan::Background::JobRunnable

  def self.servers
    ProconBypassMan.config.api_servers
  end

  def self.path
    "/api/events"
  end
end
