class ProconBypassMan::DeviceConnection::OutputReportSubCommandTable
  class HIDSubCommandResponse
    attr_accessor :sub_command, :sub_command_arg

    def initialize(sub_command: , sub_command_arg: )
      @sub_command = sub_command
      @sub_command_arg = sub_command_arg
    end

    def sub_command_with_arg
      case @sub_command
      when *SPECIAL_SUB_COMMANDS
        @sub_command
      else
        if @sub_command_arg
          "#{@sub_command}-#{@sub_command_arg}"
        else
          @sub_command
        end
      end
    end
  end

  IGNORE_SUB_COMMANDS = {
    "48-01" => true,
    "04-00" => true,
  }
  # レスポンスに引数が含まれない
  SPECIAL_SUB_COMMANDS = [
    "01",
    "02",
    "03",
    "30",
    "38", # home led
    "40",
    "48",
  ]

  EXPECTED_SUB_COMMANDS = [
    "01-04",
    "02-",
    "04-00",
    "08-00",
    "10-00",
    "10-50",
    "10-80",
    "10-98",
    "10-10",
    "10-28",
    "30-",
    "40-",
    "48-", # Enable vibration
  ]

  def initialize
    @table = {}
  end

  # @param [String] sub_command
  # @param [String] sub_command_arg
  # @return [void]
  def mask_as_send(sub_command: , sub_command_arg: )
    case sub_command
    when *SPECIAL_SUB_COMMANDS
      @table[sub_command] = false
    else
      response = HIDSubCommandResponse.new(sub_command: sub_command, sub_command_arg: sub_command_arg)
      @table[response.sub_command_with_arg] = false
    end
  end

  # @param [String] sub_command
  # @param [String] sub_command_arg
  # @return [void]
  def mark_as_receive(sub_command: , sub_command_arg: )
    response = HIDSubCommandResponse.new(sub_command: sub_command, sub_command_arg: sub_command_arg)
    if @table.key?(response.sub_command_with_arg)
      @table[response.sub_command_with_arg] = true
    end
  end

  # @param [String] sub_command
  # @param [String] sub_command_arg
  # @return [Boolean]
  def has_key?(sub_command: , sub_command_arg: )
    if IGNORE_SUB_COMMANDS["#{sub_command}-#{sub_command_arg}"]
      return true
    end

    case sub_command
    when *SPECIAL_SUB_COMMANDS
      @table.key?(sub_command)
    else
      response = HIDSubCommandResponse.new(sub_command: sub_command, sub_command_arg: sub_command_arg)
      @table.key?(response.sub_command_with_arg)
    end
  end

  # @param [String] sub_command
  # @param [String] sub_command_arg
  # @return [Boolean]
  def has_value?(sub_command: , sub_command_arg: )
    if IGNORE_SUB_COMMANDS["#{sub_command}-#{sub_command_arg}"]
      return true
    end

    response = HIDSubCommandResponse.new(sub_command: sub_command, sub_command_arg: sub_command_arg)
    !!@table[response.sub_command_with_arg]
  end

  # @return [Boolean]
  def has_unreceived_command?
    !@table.values.all?(&:itself)
  end

  # @return [String, NilClass]
  def unreceived_sub_command_with_arg
    sub_command = @table.detect { |_key, value| !value }&.first
    if(arg = ProconBypassMan::DeviceConnection::ProconSettingOverrider::SPECIAL_SUB_COMMAND_ARGS[sub_command])
      "#{sub_command}#{arg}"
    else
      sub_command
    end
  end

  # @return [Boolean]
  def completed?
    EXPECTED_SUB_COMMANDS.all? do |key|
      sub_command, sub_command_arg = key.split("-")
      has_value?(sub_command: sub_command, sub_command_arg: sub_command_arg)
    end
  end
end
