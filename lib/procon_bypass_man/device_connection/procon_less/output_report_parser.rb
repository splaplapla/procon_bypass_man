module ProconBypassMan::DeviceConnection::ProconLess
  class OutputReportParser
    def self.parse(raw_data: )
      command = raw_data[0].unpack("H*").first
      return if command == "10" && raw_data.size == 10
      case command
      when "00", "80"
        data = raw_data.unpack("H*").first
        case data
        when "0000", "8005", "8001", "8002", "8004"
          return OutputReport.new(command: data, sub_command: nil, sub_command_arg: nil)
        else
          puts "#{command} is unknown!!!!!!(1)"
        end
      when "01"
        sub_command = raw_data[10].unpack("H*").first
        case sub_command
        when "01", "02", "03", "04", "08", "21", "30", "38", "40", "48"
          return OutputReport.new(command: command, sub_command: sub_command, sub_command_arg: nil)
        when "10"
          sub_command_arg = raw_data[11..12].unpack("H*").first
          case sub_command_arg
          when "0060", "5060", "8060", "9860", "1080", "3d60", "2880"
            return OutputReport.new(command: command, sub_command: sub_command, sub_command_arg: sub_command_arg)
          else
            puts "#{command}-#{sub_command}-#{sub_command_arg} is unknown!!!!!!(2)"
          end
        end
      else
        raise "これから実装する"
      end
    end
  end
end
