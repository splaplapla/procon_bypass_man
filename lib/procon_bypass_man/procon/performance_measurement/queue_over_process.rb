require 'drb/drb'

class ProconBypassMan::Procon::PerformanceMeasurement::QueueOverProcess
  include Singleton

  @@drb_server = nil
  @@drb_server_thread = nil

  PROTOCOL = "drbunix"
  SOCKET_FILE_PATH = "/tmp/procon_bypass_man_procon_performance_queue"
  SOCKET_PATH = "#{PROTOCOL}:#{SOCKET_FILE_PATH}"

  DISTRIBUTED_CLASS = ProconBypassMan::Procon::PerformanceMeasurement::SpanQueue

  def self.start!
    return unless enable?

    FileUtils.rm_rf(SOCKET_FILE_PATH) if File.exist?(SOCKET_FILE_PATH)
    begin
      @@drb_server = DRb.start_service(SOCKET_PATH, DISTRIBUTED_CLASS.new, safe_level: 1)
    rescue Errno::EADDRINUSE => e
      ProconBypassMan.logger.error e
      raise
    end

    @@drb_server_thread =
      Thread.new do
        DRb.thread.join
      end
  end

  def self.shutdown
    if @@drb_server
      @@drb_server_thread.kill
      @@drb_server_thread = nil
      @@drb_server.stop_service
    end
  end

  def self.push(value)
    return unless enable?

    instance.distributed_queue.push(value)
  end

  def self.pop
    return unless enable?

    instance.distributed_queue.pop
  end

  def self.enable?
    ProconBypassMan.config.enable_procon_performance_measurement?
  end

  attr_reader :distributed_queue

  def initialize
    @distributed_queue = DRbObject.new_with_uri(SOCKET_PATH)
  end
end
