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
    while true
      if(data = ProconBypassMan::QueueOverProcess.pop)
        receive(data)
      else
        shutdown
        break
      end
    end
  rescue Errno::ENOENT, Errno::ECONNRESET, Errno::ECONNREFUSED => e
    ProconBypassMan.logger.debug(e)
  end

  def self.receive(data)
    # ここでmacroのqueueにpushする
  end

  def self.shutdown
    ProconBypassMan.logger.info("ProconBypassMan::RemoteMacroReceiverを終了します。")
  end
end
