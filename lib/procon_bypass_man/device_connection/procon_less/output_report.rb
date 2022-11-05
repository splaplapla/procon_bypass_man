module ProconBypassMan::DeviceConnection::ProconLess
  class OutputReport
    attr_accessor :command, :sub_command, :sub_command_arg

    def initialize(command: , sub_command: , sub_command_arg: )
      @command = command
      @sub_command = sub_command
      @sub_command_arg = sub_command_arg
    end
  end
end
