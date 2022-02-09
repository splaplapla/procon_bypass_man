module ProconBypassMan::RemoteMacroReceiver
  # forkしたプロセスで動かすクラス。sock経由で命令を受け取ってmacoのキューに積んでいく
  def self.start!
    return unless ProconBypassMan.config.enable_ws?
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
      client = UNIXSocket.new(ProconBypassMan.config.remote_macro_sock)
      if data = client.read(65536)
        client.close
        item = Marshal.load(data)
      end
    end
  rescue Errno::ENOENT, Errno::ECONNRESET, Errno::ECONNREFUSED => e
    ProconBypassMan.logger.debug(e)
  end
end
