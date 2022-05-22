require 'socket'

class ProconBypassMan::ProconDisplay::Server
  PORT = 9900

  def self.start!
    Thread.new do
      new.start_with_foreground
    end
  end

  def start_with_foreground
    server = TCPServer.new('127.0.0.1', PORT)
    loop do
      socket = server.accept
      socket.write(response)
      socket.close
    end
  rescue Errno::EADDRINUSE => e
    ProconBypassMan::SendErrorCommand.execute(error: e)
  end

  def response
    ProconBypassMan::ProconDisplay::Status.instance.to_json
  end
end

# client例
# require 'socket'
# TCPSocket.open('127.0.0.1', 9900){ |s|
#   print s.read
# }
