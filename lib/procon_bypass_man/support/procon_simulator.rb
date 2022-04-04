class ProconBypassMan::ProconSimulator
  def initialize
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
        input_response
      else
        puts "unknown!!!!!!"
      end
    when "01"
      sub_command = raw_data[10].unpack("H*").first
      case sub_command
      when "03" # Set NFC/IR MCU configuration
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

  def input_response
    response("309e810080007cc8788f28700a78fd0d00f90ff5ff0100080075fd0900f70ff5ff0200070071fd0900f70ff5ff02000700000000000000000000000000000000")
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
end
