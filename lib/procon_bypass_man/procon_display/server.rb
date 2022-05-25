require 'socket'

module ProconBypassMan::ProconDisplay
  class Server
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
        response = ServerApp.new(
          HttpRequest.parse(conn).to_hash
        ).call
        conn.write(response)
        conn.close
      end
    rescue Errno::EADDRINUSE => e
      ProconBypassMan::SendErrorCommand.execute(error: e)
    end
  end
end
