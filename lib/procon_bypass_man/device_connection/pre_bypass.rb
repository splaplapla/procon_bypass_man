class ProconBypassMan::DeviceConnection::PreBypass
  def initialize(gadget: , procon: )
    @gadget = gadget
    @procon = procon
    @output_report_reminder = ProconBypassMan::DeviceConnection::OutputReportReminder.new
  end

  # NOTE 脳死でx01とx21をバイパスする
  # NOTE 返事が返ってくるまで任意のx01(home led光らせる)をプロコンに送りつける
  def execute!
    loop do
      raw_data = read_from_switch
      binary = ProconBypassMan::Domains::InboundProconBinary.new(binary: raw_input)
      if binary.rumble?
        send_to_procon(binary.raw)
        next
      end

      if @output_report_reminder.has_unreceived_command?
        send_to_procon(@output_report_reminder.unreceived_byte)
      else
        if(configuration_step = @configuration_steps.shift)
        @output_report_reminder.mark_as_send(step: configuration_step)
        send_to_procon(@output_report_reminder.byte_of(step: configuration_step))
        else
        end
      end
    end
  end
end
