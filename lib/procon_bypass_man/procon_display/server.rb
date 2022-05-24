require 'socket'

class ProconBypassMan::ProconDisplay::Server
  PORT = 9900

  def self.start!
    Thread.new do
      new.start_with_foreground
    end
  end

  def start_with_foreground
    server = TCPServer.new('0.0.0.0', PORT)
    loop do
      conn = server.accept
      response = App.new(
        HttpRequest.parse(conn).to_hash
      ).call
      conn.write(response)
      conn.close
    end
  rescue Errno::EADDRINUSE => e
    ProconBypassMan::SendErrorCommand.execute(error: e)
  end
end

# client例
# require 'socket'
# TCPSocket.open('127.0.0.1', 9900){ |s|
#   print s.read
# }
