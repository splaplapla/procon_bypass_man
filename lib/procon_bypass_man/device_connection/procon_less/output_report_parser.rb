module ProconBypassMan::DeviceConnection::ProconLess
  class OutputReportParser
    def self.parse(raw_data: )
      first_data_part = raw_data[0].unpack("H*").first
      return if first_data_part == "10" && raw_data.size == 10
      case first_data_part
      when "00", "80"
        data = raw_data.unpack("H*").first
        case data
        when "0000", "8005", "8001", "8002", "8004"
          return OutputReport.new(command: data, sub_command: nil, sub_command_arg: nil)
        else
          puts "#{raw_data.unpack("H*").first} is unknown!!!!!!(1)"
        end
      when "01"
        sub_command = raw_data[10].unpack("H*").first
        case sub_command
        when "01" # Bluetooth manual pairing
          return OutputReport.new(command: "01", sub_command: "01", sub_command_arg: nil)
        when "02" # Request device info
          return OutputReport.new(command: "01", sub_command: "02", sub_command_arg: nil)
        when "03", "08", "30", "38", "40", "48" # 01-03, 01-8, 01-30, 01-38, 01-40, 01-48
          return OutputReport.new(command: "01", sub_command: sub_command, sub_command_arg: nil)
        when "04" # Trigger buttons elapsed time
          return OutputReport.new(command: "01", sub_command: "04", sub_command_arg: nil)
        when "21" # Set NFC/IR MCU configuration
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
        raise "これから実装する"
      end
    end
  end
end
