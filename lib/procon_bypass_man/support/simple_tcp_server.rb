require 'socket'

class SimpleTCPServer
  def initialize
    @connections = []
  end

  def start_server(host, port)
    @server = TCPServer.new(host, port)
  end

  def run
    loop do
      readable, _ = IO.select(@connections + [@server])
      readable.each do |socket|
        if socket == @server
          client = @server.accept
          post_init(client)
          @connections << client
        else
          data = socket.gets
          if data.nil?
            @connections.delete(socket)
            unbind
            socket.close
          else
            receive_data(socket, data)
          end
        end
      end
    rescue Errno::EBADF, IOError => e
      unbind
      @connections = []
      @server.close
    end
  end

  def shutdown
    @server.close
  end

  # @return [Integer]
  def connections_size
    @connections.size
  end

  def post_init(client)
    # Override this method
  end

  def receive_data(client, data)
    # Override this method
  end

  def unbind
    # Override this method
  end
end
