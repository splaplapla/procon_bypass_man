class ProconBypassMan::ProconSimulator
  def initialize
    @response_counter = 0
  end

  def read_once
    raw_data = read
    first_data_part = raw_data[0].unpack("H*").first
    case first_data_part
    when "00", "80"
      data = raw_data.unpack("H*").first
      puts(">>> #{data}")
      case data
      when "0000", "8005"
        return data # do not need response
      when "8001"
        response("810100032dbd42e9b698000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
      when "8002"
        response("81020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
      when "8004"
        start_procon_simulator_thread
        return nil
      else
        puts "unknown!!!!!!"
      end
    when "01"
      sub_command = raw_data[10].unpack("H*").first
      case sub_command
      when "03" # Set input report mode
        response("219a810080007bd8789128700a800300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
      end
    end
  end

  private

  def read
    gadget.read_nonblock(64)
  end

  def response(data)
    puts("<<< #{data}")
    write(data)
    return data
  end

  def make_response(code, cmd, buf)
    [code, cmd, buf].join
  end

  def input_response
    # response("309e810080007cc8788f28700a78fd0d00f90ff5ff0100080075fd0900f70ff5ff0200070071fd0900f70ff5ff02000700000000000000000000000000000000")
    make_response("30", response_counter, "810080007cc8788f28700a78fd0d00f90ff5ff0100080075fd0900f70ff5ff0200070071fd0900f70ff5ff02000700000000000000000000000000000000")
  end

  def response_counter
    if @response_counter >= 256
      @response_counter = 0
    else
      @response_counter = @response_counter + 1
    end
    @response_counter
  end

  def write(data)
    # gadget.write_nonblock([data].pack("H*"))
  end

  def gadget
    @gadget ||= File.open('/dev/hidg0', "w+b")
  end

  def uart_response
  end

  def spi_response
  end

  def start_procon_simulator_thread
    Thread.start do
      loop do
        write(input_response)
        sleep(0.03)
      rescue IO::EAGAINWaitReadable
        retry
      end
    end
  end
end
