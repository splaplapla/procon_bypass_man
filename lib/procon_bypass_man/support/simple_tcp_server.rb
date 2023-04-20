require 'socket'

class SimpleTCPServer
  def initialize(host, port)
    @host = host
    @port = port
  end

  def start_server
    @connections = []
    @server = TCPServer.new(@host, @port)
  end

  def run
    loop do
      readable, _ = IO.select(@connections + [@server])
      readable.each do |socket|
        if socket == @server
          client = @server.accept
          post_init
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

  def post_init
    # Override this method
  end

  def receive_data(data)
    # Override this method
  end

  def unbind
    # Override this method
  end
end
