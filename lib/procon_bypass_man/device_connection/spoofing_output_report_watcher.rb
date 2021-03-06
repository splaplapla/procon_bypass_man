class ProconBypassMan::DeviceConnection::SpoofingOutputReportWatcher
  include ProconBypassMan::DeviceConnection::OutputReportMarkerable

  def initialize(expected_sub_commands: )
    @timer = ProconBypassMan::SafeTimeout.new
    @hid_sub_command_request_table = ProconBypassMan::DeviceConnection::OutputReportSubCommandTable.new
    @expected_sub_commands = expected_sub_commands
  end

  # @return [Boolean]
  def has_unreceived_command?
    @hid_sub_command_request_table.has_unreceived_command?
  end

  # @return [String, NilClass]
  def unreceived_sub_command_with_arg
    @hid_sub_command_request_table.unreceived_sub_command_with_arg
  end

  # @return [Boolean]
  def completed?
    @expected_sub_commands.all? do |sub_command, sub_command_arg|
      @hid_sub_command_request_table.has_value?(sub_command: sub_command, sub_command_arg: sub_command_arg)
    end
  end

  # @return [Boolean]
  def timeout_or_completed?
    if @timer.timeout?
      ProconBypassMan.logger.info "[procon setting override] プロコンの設定上書き処理がタイムアウトしました"
      return true
    end

    if completed?
      ProconBypassMan.logger.info "[procon setting override] プロコンの設定上書き処理が想定通り終了しました"
      return true
    end
  end
end
