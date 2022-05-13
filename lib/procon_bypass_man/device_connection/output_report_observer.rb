class ProconBypassMan::DeviceConnection::OutputReportObserver
  class HIDSubCommandResponse
    attr_accessor :sub_command, :sub_command_arg

    def self.parse(data)
      if sub_command = data[28..29]
        sub_command_arg = data[30..31]
        new(sub_command: sub_command, sub_command_arg: sub_command_arg)
      else
        raise "could not parse"
      end
    end

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

  class HIDSubCommandRequestTable
    def initialize(timeout: )
      @table = {}
    end

    def has_key?(sub_command: , sub_command_arg: )
      case sub_command
      when *SPECIAL_SUB_COMMANDS
        @table.key?(sub_command)
      else
        response = HIDSubCommandResponse.new(sub_command: sub_command, sub_command_arg: sub_command_arg)
        @table.key?(response.sub_command_with_arg)
      end
    end

    def mask_as_send(sub_command: , sub_command_arg: )
      case sub_command
      when *SPECIAL_SUB_COMMANDS
        @table[sub_command] = false
      else
        response = HIDSubCommandResponse.new(sub_command: sub_command, sub_command_arg: sub_command_arg)
        @table[response.sub_command_with_arg] = false
      end
    end

    def mask_as_receive(sub_command: , sub_command_arg: )
      response = HIDSubCommandResponse.new(sub_command: sub_command, sub_command_arg: sub_command_arg)
      if @table.key?(response.sub_command_with_arg)
        @table[response.sub_command_with_arg] = true
      end
    end

    def has_value?(sub_command: , sub_command_arg: )
      response = HIDSubCommandResponse.new(sub_command: sub_command, sub_command_arg: sub_command_arg)
      @table[response.sub_command_with_arg] || false
    end
  end

  # レスポンスに引数が含まれない
  SPECIAL_SUB_COMMANDS = ["30", "40", "03", "02", "01"]
  IGNORE_OBSERVE_SUB_COMMANDS = { "48-01" => true }
  EXPECTED_SUB_COMMANDS = %w(
    01-04
    02-00
    03-30
    04-00
    08-00
    10-00
    10-10
    10-28
    10-3d
    10-50
    10-80
    10-98
    30-01
    40-01
    48-00
  ).map{ |x| x.split("-") }

  def initialize
    @hid_sub_command_request_table = HIDSubCommandRequestTable.new
    @timer = ProconBypassMan::SafeTimeout.new
  end

  # @return [void]
  def mark_as_send(raw_data)
    data = raw_data.unpack("H*").first
    case data
    when /^01/
      sub_command = data[20..21]
      sub_command_arg = data[22..23]

      if IGNORE_OBSERVE_SUB_COMMANDS["#{sub_command}-#{sub_command_arg}"]
        return true
      end

      @hid_sub_command_request_table.mask_as_send(sub_command: sub_command, sub_command_arg: sub_command_arg)
    end
  end

  # @return [Boolean]
  def sent?(sub_command: , sub_command_arg: )
    if IGNORE_OBSERVE_SUB_COMMANDS["#{sub_command}-#{sub_command_arg}"]
      return true
    end

    @hid_sub_command_request_table.has_key?(sub_command: sub_command, sub_command_arg: sub_command_arg)
  end

  INPUT_REPORT_FORMAT = /^21/
  def mask_as_receive(raw_data)
    data = raw_data.unpack("H*").first
    case data
    when INPUT_REPORT_FORMAT
      response = HIDSubCommandResponse.parse(data)
      @hid_sub_command_request_table.mask_as_receive(sub_command: response.sub_command, sub_command_arg: response.sub_command_arg)
    end
  end

  # @return [Boolean]
  def received?(sub_command: , sub_command_arg: )
    @hid_sub_command_request_table.has_value?(sub_command: sub_command, sub_command_arg: sub_command_arg)
  end

  # @return [Boolean]
  def completed?
    EXPECTED_SUB_COMMANDS.all? do |sub_command, sub_command_arg|
      @hid_sub_command_request_table.has_value?(sub_command: sub_command, sub_command_arg: sub_command_arg)
    end
  end

  # @return [Boolean]
  # @raise [Timeout::Error]
  def timeout_or_completed?
    if @timer.timeout?
      ProconBypassMan.logger.error "pre_bypassフェーズがタイムアウトしました"
      return true
    end

    return true if completed?
  end
end
