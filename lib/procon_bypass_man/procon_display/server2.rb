module ProconBypassMan::ProconDisplay::Server2 < SimpleTCPServer
  def self.run(read_pipe)
    server = new('0.0.0.0', 8000, read_pipe)
    server.start_server
    server.run
  end

  def initialize(host, port, read_pipe)
    super(host, port)
    @read_pipe = read_pipe
  end

  # TODO: バッファリングしたい
  def receive_data(socket, _data)
    # TODO: IO::EAGAINWaitReadableが起きるまでread_pipe.read_nonblock(1024)を実行する。改行未満の部分を捨てる。取得しまくったら200ms分の履歴を返す
    pipe_data = @read_pipe.gets
    puts pipe_data
    # TODO: HTTP形式で返す
    socket.puts(pipe_data)
  end
end
