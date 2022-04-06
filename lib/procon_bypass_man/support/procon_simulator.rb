class ProconBypassMan::ProconSimulator
  attr_accessor :gadget, :procon
  MAC_ADDR = '00005e00535e'

  UART_INITIAL_INPUT = '81008000f8d77a22c87b0c'
  UART_DEVICE_INFO = '0348030298b6e942bd2d0301'

  def initialize
    @response_counter = 0
    @procon_simulator_thread = nil
  end

  def run
    init_devices

    loop do
      read_once
    end
  end

  def read_once
    raw_data = read
    first_data_part = raw_data[0].unpack("H*").first

    return if first_data_part == "10" && raw_data.size == 10

    case first_data_part
    when "00", "80"
      data = raw_data.unpack("H*").first
      puts(">>> #{data}")
      case data
      when "0000", "8005"
        return data # do not need response
      when "8001"
        response(
          make_response("81", "01", "0003#{MAC_ADDR}")
        )
      when "8002"
        response(
          make_response("81", "02", [])
        )
      when "8004"
        start_procon_simulator_thread
        return nil
      else
        puts "#{raw_data.unpack("H*").first} is unknown!!!!!!(1)"
      end
    when "01"
      sub_command = raw_data[10].unpack("H*").first

      case sub_command
      when "01" # Bluetooth manual pairing
        uart_response("81", sub_command, "03")
      when "02" # Request device info
        uart_response("82", sub_command, "03480302#{MAC_ADDR.reverse}0301")
      when "03", "08", "30", "38", "40", "48"
        uart_response("80", sub_command, [])
      when "04" # Trigger buttons elapsed time
        uart_response("83", sub_command, [])
      when "21" # Set NFC/IR MCU configuration
        uart_response("a0", sub_command, "0100ff0003000501")
      when "10"
        arg = raw_data[11..12].unpack("H*").first

        case arg
        when "0060" # Serial number
          spi_response(arg, 'ffffffffffffffffffffffffffffffff')
        when "5060" # Controller Color
          spi_response(arg, 'bc114 275a928 ffffff ffffff ff'.gsub(" ", "")) # Raspberry Color
        when "8060" # Factory Sensor and Stick device parameters
          spi_response(arg, '50fd0000c60f0f30619630f3d41454411554c7799c333663')
        when "9860" # Factory Stick device parameters 2
          spi_response(arg, '0f30619630f3d41454411554c7799c333663')
        when "1080" # User Analog sticks calibration
          spi_response(arg, 'ffffffffffffffffffffffffffffffffffffffffffffb2a1')
        when "3d60" # Factory configuration & calibration 2
          spi_response(arg, 'ba156211b87f29065bffe77e0e36569e8560ff323232ffffff')
        when "2880" # User 6-Axis Motion Sensor calibration
          spi_response(arg, 'beff3e00f001004000400040fefffeff0800e73be73be73b')
        else
          puts "#{first_data_part}-#{sub_command}-#{arg} is unknown!!!!!!(2)"
        end
      end
    else
      puts "#{first_data_part}} is unknown!!!!!!(3)"
    end
  end

  private

  def read
    gadget.read_nonblock(64)
  rescue IO::EAGAINWaitReadable
    retry
  end

  # @return [String] switchに入力する用の128byte data
  def make_response(code, cmd, buf)
    buf = [code, cmd, buf].join
    buf.ljust(128, "0")
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
    response(
      make_response("30", response_counter, "810080007cc8788f28700a78fd0d00f90ff5ff0100080075fd0900f70ff5ff0200070071fd0900f70ff5ff02000700000000000000000000000000000000")
    )
  end

  def response(data)
    write(data)
    return data
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
    puts("<<< #{data}")
    @gadget.write_nonblock([data].pack("H*"))
  rescue IO::EAGAINWaitReadable
    retry
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

  def init_devices
    ProconBypassMan::UsbDeviceController.init

    if path = ProconBypassMan::DeviceProconFinder.find
      @procon = File.open(path, "w+b")
      ProconBypassMan.logger.info "proconのデバイスファイルは#{path}を使います"
    else
      raise(ProconBypassMan::DeviceConnector::NotFoundProconError)
    end
    @gadget = File.open('/dev/hidg0', "w+b")

    ProconBypassMan::UsbDeviceController.reset
  end
end
