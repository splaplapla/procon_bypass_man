require 'drb/drb'

# NOTE マスタープロセスでstart_distributed_object!をコールする必要がある
#      forkをしたらそのさきでDRb.start_serviceをコールする必要がある
module ProconBypassMan::CanOverProcess
  PROTOCOL = "drbunix".freeze

  def self.extended(mod)
    mod.singleton_class.attr_accessor :drb_server, :drb_server_thread
  end

  # @return [void]
  def start_distributed_object!
    return unless enable?

    FileUtils.rm_rf(socket_file_path) if File.exist?(socket_file_path)
    begin
      self.drb_server = DRb.start_service(socket_path, distributed_class.new, safe_level: 1)
    rescue Errno::EADDRINUSE => e
      ProconBypassMan.logger.error e
      raise
    end

    self.drb_server_thread =
      Thread.new do
        DRb.thread.join
      end
  end
  alias start! start_distributed_object!

  # @return [void]
  def shutdown_distributed_object
    if self.drb_server
      self.drb_server_thread.kill
      self.drb_server_thread = nil
      self.drb_server.stop_service
    end
  end
  alias shutdown shutdown_distributed_object

  # @return [Boolean]
  def enable?
    raise NotImplementedError
  end

  # @return [String]
  def socket_file_path
    raise NotImplementedError
  end

  # @return [any]
  def distributed_class
    raise NotImplementedError
  end

  # @return [String]
  def socket_path
    "#{PROTOCOL}:#{socket_file_path}".freeze
  end
end
