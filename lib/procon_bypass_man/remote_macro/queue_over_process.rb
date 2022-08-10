class ProconBypassMan::RemoteMacro::QueueOverProcess
  extend ProconBypassMan::CanOverProcess

  include Singleton

  attr_reader :distributed_queue

  # @override
  def self.enable?
    ProconBypassMan.config.enable_remote_macro?
  end

  # @override
  def self.distributed_class
    Queue
  end

  # @override
  def self.socket_file_path
    "/tmp/procon_bypass_man_remote_macro_queue".freeze
  end

  def self.push(value)
    return unless enable?

    instance.distributed_queue.push(value)
  end

  def self.pop
    return unless enable?

    instance.distributed_queue.pop
  end

  def self.clear
    return unless enable?

    instance.distributed_queue.clear
  end

  def initialize
    @distributed_queue = DRbObject.new_with_uri(self.class.socket_path)
  end
end
