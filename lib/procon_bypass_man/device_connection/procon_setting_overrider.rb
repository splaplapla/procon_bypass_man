class ProconBypassMan::DeviceConnection::ProconSettingOverrider
  attr_accessor :procon, :output_report_watcher, :output_report_generator

  def initialize(procon: )
    @setting_steps = [:home_led_on]
    self.output_report_generator = ProconBypassMan::DeviceConnection::OutputReportGenerator.new
    self.procon = procon
    self.output_report_watcher = ProconBypassMan::DeviceConnection::SpoofingOutputReportWatcher.new
  end

  def execute!
    loop do
      run_once

      if output_report_watcher.timeout_or_completed?
        break
      end
    end
  end

  def run_once
    raw_data = non_blocking_read_procon

    if /^21/ =~ raw_data.unpack("H*").first
      output_report_watcher.mark_as_receive(raw_data)
      if output_report_watcher.has_unreceived_command?
        send_procon(output_report_generator.generate_by_sub_command_with_arg(output_report_watcher.unreceived_sub_command_with_arg))
      else
        if(setting_step = @setting_steps.shift)
          raw_data = output_report_generator.generate_by_step(setting_step)
          output_report_watcher.mark_as_send(raw_data)
          send_procon(raw_data)
        else
          return
        end
      end
    end
  end

  private

  # @raise [IO::EAGAINWaitReadable]
  # @return [String]
  def non_blocking_read_procon
    raw_data = procon.read_nonblock(64)
    return raw_data
  end

  # @return [void]
  def send_procon(raw_data)
    procon.write_nonblock(raw_data)
  end
end
