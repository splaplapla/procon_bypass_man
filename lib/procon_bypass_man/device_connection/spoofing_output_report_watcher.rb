class ProconBypassMan::DeviceConnection::SpoofingOutputReportWatcher
  OUTPUT_REPORT_FORMAT = /^01/
  INPUT_REPORT_FORMAT = /^21/

  def initialize
    @timer = ProconBypassMan::SafeTimeout.new
    @hid_sub_command_request_table = ProconBypassMan::DeviceConnection::OutputReportSubCommandTable.new
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

  def has_unreceived_command?
    @hid_sub_command_request_table.has_unreceived_command?
  end

  def unreceived_sub_command_with_arg
    @hid_sub_command_request_table.unreceived_sub_command_with_arg
  end

  def timeout_or_completed?
    if @timer.timeout?
      ProconBypassMan.logger.info "[procon setting override] プロコンの設定上書き処理がタイムアウトしました"
      return true
    end

    if completed?
      ProconBypassMan.logger.info "[observer] pre_bypassフェーズが想定通り終了しました"
      return true
    end
  end
end
