class ProconBypassMan::QueueOverProcess
  attr_reader :drb

  def self.start!
    return unless ProconBypassMan.config.enable_remote_macro?
    require 'drb/drb'

    FileUtils.rm_rf(file_path) if File.exist?(file_path)
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
      sleep(1)
      retry
    end
  end

  def self.shutdown
    if @drb
      @drb.stop_service
    end
  end

  def self.push(value)
    return unless ProconBypassMan.config.enable_remote_macro?

    drb.push(value)
  end

  def self.pop
    return unless ProconBypassMan.config.enable_remote_macro?

    drb.pop
  end

  def self.drb
    return unless ProconBypassMan.config.enable_remote_macro?

    @@drb ||= new.drb
  end

  PROTOCOL = "drbunix"
  def self.url
    "#{PROTOCOL}:/tmp/procon_bypass_man_queue"
  end

  def self.file_path
    url.gsub("#{PROTOCOL}:", "")
  end

  def initialize
    @drb = DRbObject.new_with_uri(self.class.url)
  end
end
