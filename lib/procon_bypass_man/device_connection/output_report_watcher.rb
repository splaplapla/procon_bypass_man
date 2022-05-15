class ProconBypassMan::DeviceConnection::OutputReportWatcher
  include ProconBypassMan::DeviceConnection::Markerable

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
    @hid_sub_command_request_table = ProconBypassMan::DeviceConnection::OutputReportSubCommandTable.new
    @timer = ProconBypassMan::SafeTimeout.new
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
      ProconBypassMan.logger.info "[pre_bypass] pre_bypassフェーズがタイムアウトしました"
      return true
    end

    if completed?
      ProconBypassMan.logger.info "[pre_bypass] pre_bypassフェーズが想定通り終了しました"
      return true
    end
  end
end
