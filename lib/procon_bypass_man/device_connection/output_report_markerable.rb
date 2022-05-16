module ProconBypassMan::DeviceConnection::OutputReportMarkerable
  OUTPUT_REPORT_FORMAT = /^01/
  INPUT_REPORT_FORMAT = /^21/

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
end
