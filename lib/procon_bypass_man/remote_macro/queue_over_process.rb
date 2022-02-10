class ProconBypassMan::QueueOverProcess
  attr_reader :drb

  def self.start!
    return unless ProconBypassMan.config.enable_remote_macro?
    require 'drb/drb'

    FileUtils.rm_rf(url) if File.exist?(url)
    begin
      DRb.start_service(url, Queue.new, safe_level: 1)
    rescue Errno::EADDRINUSE => e
      ProconBypassMan.logger.error e
      raise
    end

    Thread.new do
      DRb.thread.join
    rescue => e
      ProconBypassMan::SendErrorCommand.execute(error: e)
      retry
    end
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
    "drbunix:/tmp/procon_bypass_man_queue"
  end

  def initialize
    @drb = DRbObject.new_with_uri(self.class.url)
  end
end
