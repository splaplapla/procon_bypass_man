class ProconBypassMan::BaseJob
  extend ProconBypassMan::Background::JobRunnable

  def self.servers
    raise NotImplementedError
  end
end
