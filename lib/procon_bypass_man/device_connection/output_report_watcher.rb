class ProconBypassMan::DeviceConnection::OutputReportWatcher
  include ProconBypassMan::DeviceConnection::OutputReportMarkerable

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
    @hid_sub_command_request_table.completed?
  end

  # @return [Boolean]
  # @raise [Timeout::Error]
  def timeout_or_completed?
    if @timer.timeout?
      ProconBypassMan::SendErrorCommand.execute(error: "[pre_bypass] pre_bypassフェーズがタイムアウトしました")
      return true
    end

    if completed?
      ProconBypassMan.logger.info "[pre_bypass] pre_bypassフェーズが想定通り終了しました"
      return true
    end
  end
end
