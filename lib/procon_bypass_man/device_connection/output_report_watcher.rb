class ProconBypassMan::DeviceConnection::OutputReportWatcher
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

  OUTPUT_REPORT_FORMAT = /^01/
  INPUT_REPORT_FORMAT = /^21/

  def initialize
    @hid_sub_command_request_table = ProconBypassMan::DeviceConnection::OutputReportSubCommandTable.new
    @timer = ProconBypassMan::SafeTimeout.new
  end

  # @param [String] raw_data
  # @return [void]
  def mark_as_send(raw_data)
    data = raw_data.unpack("H*").first
    case data
    when OUTPUT_REPORT_FORMAT
      sub_command = data[20..21]
      sub_command_arg = data[22..23]
      @hid_sub_command_request_table.mask_as_send(sub_command: sub_command, sub_command_arg: sub_command_arg)
    end
  end

  # @param [String] raw_data
  # @return [void]
  def mark_as_receive(raw_data)
    data = raw_data.unpack("H*").first
    case data
    when INPUT_REPORT_FORMAT
      sub_command = data[28..29]
      sub_command_arg = data[30..31]
      @hid_sub_command_request_table.mark_as_receive(sub_command: sub_command, sub_command_arg: sub_command_arg)
    end
  end

  # @param [String] sub_command
  # @param [String] sub_command_arg
  # @return [Boolean]
  def sent?(sub_command: , sub_command_arg: )
    @hid_sub_command_request_table.has_key?(sub_command: sub_command, sub_command_arg: sub_command_arg)
  end

  # @param [String] sub_command
  # @param [String] sub_command_arg
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
      ProconBypassMan.logger.info "[observer] pre_bypassフェーズがタイムアウトしました"
      return true
    end

    if completed?
      ProconBypassMan.logger.info "[observer] pre_bypassフェーズが想定通り終了しました"
      return true
    end
  end
end
