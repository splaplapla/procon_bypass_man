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
        "#{@sub_command}-#{@sub_command_arg}"
      end
    end
  end

  IGNORE_SUB_COMMANDS = { "48-01" => true }
  # レスポンスに引数が含まれない
  SPECIAL_SUB_COMMANDS = ["30", "40", "03", "02", "01", "38"]
  # レスポンスに引数が含まれないが、再送時に引数を含めたい。ワークアラウンド
  SPECIAL_SUB_COMMAND_ARGS =  { "38" => "F1F" }

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
    if(arg = SPECIAL_SUB_COMMAND_ARGS[sub_command])
      "#{sub_command}#{arg}"
    else
      sub_command
    end
  end
end
