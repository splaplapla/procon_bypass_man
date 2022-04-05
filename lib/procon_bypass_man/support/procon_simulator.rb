class ProconBypassMan::ProconSimulator
  UART_INITIAL_INPUT = '81008000f8d77a22c87b0c'
  UART_DEVICE_INFO = '0348030298b6e942bd2d0301'

  def initialize
    @response_counter = 0
    @procon_simulator_thread = nil
  end

  def read_once
    raw_data = read
    first_data_part = raw_data[0].unpack("H*").first
    binding.pry if $aaaa

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
      when "01" # Bluetooth manual pairing
        uart_response("81", sub_command, "03")
      when "02" # Request device info
        uart_response("82", sub_command, "0348030298b6e942bd2d0301") # including macadress
      when "04" # Trigger buttons elapsed time
        uart_response("83", sub_command, [])
      when "48" # 01000000000000000000480000000000000000000000000000000000000000000000000000000000000000000000000000
        uart_response("80", sub_command, [])
      when "03" # Set input report mode
        uart_response("80", sub_command, [])
      when "08"
        uart_response("80", sub_command, [])
      when "10"
        arg = raw_data[11..12].unpack("H*").first

        case arg
        when "0060" # Serial number
          spi_response(arg, 'ffffffffffffffffffffffffffffffff')
        when "5060" # Controller Color
          spi_response(arg, 'bc114 275a928 ffffff ffffff ff'.gsub(" ", "")) # Raspberry Color
        else
          binding.pry if $aaaa
        end
      end
    end
  end

  private

  # UART_INITIAL_INPUT = '810080007bd8789028700382020348030298b6e942bd2d030100000000000000000000000000000000000000000000000000000000000000000000000000'

  def read
    gadget.read_nonblock(64)
  end

  def response(data)
    write(data)
    return data
  end

  def spi_response(addr, data)
    buf = [addr, "00", "00", "10", data].join
    uart_response("90", "10", buf)
  end

  def uart_response(code, subcmd, data)
    buf = [UART_INITIAL_INPUT, code, subcmd, data].join
    response(
      make_response("21", response_counter, buf)
    )
  end

  def input_response
    # response("309e810080007cc8788f28700a78fd0d00f90ff5ff0100080075fd0900f70ff5ff0200070071fd0900f70ff5ff02000700000000000000000000000000000000")
    response(
      make_response("30", response_counter, "810080007cc8788f28700a78fd0d00f90ff5ff0100080075fd0900f70ff5ff0200070071fd0900f70ff5ff02000700000000000000000000000000000000")
    )
  end

  # @return [String] switchに入力する用の128byte data
  def make_response(code, cmd, buf)
    buf = [code, cmd, buf].join
    buf.ljust(128, "0")
  end

  def response_counter
    if @response_counter >= 256
      @response_counter = 0
    else
      @response_counter = @response_counter + 1
    end
    @response_counter.to_s.rjust(2, "0")
  end

  def write(data)
    return
    puts("<<< #{data}")
    gadget.write_nonblock([data].pack("H*"))
  end

  def gadget
    @gadget ||= File.open('/dev/hidg0', "w+b")
  end

  def start_procon_simulator_thread
    @procon_simulator_thread =
      Thread.start do
        loop do
          input_response
          sleep(0.03)
        rescue IO::EAGAINWaitReadable
          retry
        end
      end
  end
end
