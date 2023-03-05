# FIXME: BypassProcessSenderみたいにする
class ProconBypassMan::RemoteActionReceiver
  # forkしたプロセスで動かすクラス。sock経由で命令を受け取ってmacoのキューに積んでいく
  def self.start_with_foreground!
    return unless ProconBypassMan.config.enable_remote_action?

    run
  end

  def self.start!
    return unless ProconBypassMan.config.enable_remote_action?

    Thread.start do
      start_with_foreground!
    end
  end

  def self.run
    while(task = ProconBypassMan::RemoteAction::QueueOverProcess.pop)
      receive(task)
    end
    shutdown
  rescue Errno::ENOENT, Errno::ECONNRESET, Errno::ECONNREFUSED => e
    ProconBypassMan.logger.debug(e)
  end


  # @param [ProconBypassMan::RemoteAction::Task] task
  def self.receive(task)
    ProconBypassMan.logger.info "[remote macro][receiver] name: #{task.name}, uuid: #{task.uuid}, steps: #{task.steps}, type: #{task.type}"
    ProconBypassMan::RemoteAction::TaskQueueInProcess.push(task)
    true
  end

  def self.shutdown
    ProconBypassMan.logger.info("ProconBypassMan::RemoteMacroReceiverを終了します。")
  end
end
