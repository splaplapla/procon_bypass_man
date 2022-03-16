class ProconBypassMan::RemoteMacroReceiver
  # forkしたプロセスで動かすクラス。sock経由で命令を受け取ってmacoのキューに積んでいく
  def self.start_with_foreground!
    return unless ProconBypassMan.config.enable_remote_macro?

    run
  end

  def self.start!
    return unless ProconBypassMan.config.enable_remote_macro?

    Thread.start do
      start_with_foreground!
    end
  end

  def self.run
    while(data = ProconBypassMan::QueueOverProcess.pop)
      receive(data)
    end
    shutdown
  rescue Errno::ENOENT, Errno::ECONNRESET, Errno::ECONNREFUSED => e
    ProconBypassMan.logger.debug(e)
  end

  def self.receive(data)
    ProconBypassMan.logger.info "[remote macro][receiver] action: #{dada.action}, uuid: #{data.uuid}, steps: #{data.steps}"
    # ここでmacroのqueueにpushする
  end

  def self.shutdown
    ProconBypassMan.logger.info("ProconBypassMan::RemoteMacroReceiverを終了します。")
  end
end
