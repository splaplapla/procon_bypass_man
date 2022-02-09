class ProconBypassMan::RemoteMacroReceiver
  # forkしたプロセスで動かすクラス。sock経由で命令を受け取ってmacoのキューに積んでいく
  def self.start!
    return unless ProconBypassMan.config.enable_remote_macro?
    instance = new

    Thread.start do
      loop do
        instance.run
      rescue
        retry
      end
    end
  end

  def run
    while 1
      data = ProconBypassMan::QueueOverProcess.pop
      # ここでmacroのqueueにpushする
    end
    ProconBypassMan::QueueOverProcess.pop
  rescue Errno::ENOENT, Errno::ECONNRESET, Errno::ECONNREFUSED => e
    ProconBypassMan.logger.debug(e)
  end
end
