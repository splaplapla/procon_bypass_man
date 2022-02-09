class ProconBypassMan::QueueOverProcess
  def self.start!
    return unless ProconBypassMan.config.enable_ws?

    require 'drb/drb'

    # portをランダムにする
    begin
      DRb.start_service(url, Queue.new, safe_level: 1)
    rescue Errno::EADDRINUSE # Address already in use
      # TODO どうする
    end

    Thread.new do
      DRb.thread.join
    rescue => e
      ProconBypassMan::SendErrorCommand.execute(error: e)
      retry
    end
  end

  attr_reader :drb

  def initialize
    @drb = DRbObject.new_with_uri(self.class.url)
  end

  def self.push(value)
    drb.push(value)
  end

  def self.pop
    drb.pop
  end

  def self.drb
    @@drb ||= new.drb
  end

  def self.url
    "druby://localhost:8787"
  end
end
