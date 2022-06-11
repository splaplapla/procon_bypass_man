class ProconBypassMan::BaseJob
  extend ProconBypassMan::Background::JobPerformable

  def self.servers
    raise NotImplementedError
  end
end
