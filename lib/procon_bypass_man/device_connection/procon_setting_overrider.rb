class ProconBypassMan::DeviceConnection::ProconSettingOverrider
  attr_accessor :procon, :output_report_watcher, :output_report_generator

  SETTING_STEPS = [:home_led_on]

  def initialize(procon: )
    @setting_steps = SETTING_STEPS.dup
    self.procon = ProconBypassMan::DeviceModel.new(procon)
    self.output_report_watcher = ProconBypassMan::DeviceConnection::SpoofingOutputReportWatcher.new
    self.output_report_generator = ProconBypassMan::DeviceConnection::OutputReportGenerator.new
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

    ProconBypassMan.logger.info "[procon_setting_overrider] <<< #{raw_data.unpack("H*").first}"
    if /^21/ =~ raw_data.unpack("H*").first
      output_report_watcher.mark_as_receive(raw_data)
      if output_report_watcher.has_unreceived_command?
        re_override_setting_by_cmd(output_report_watcher.unreceived_sub_command_with_arg)
      else
        if(setting_step = @setting_steps.shift)
          override_setting_by_step(setting_step)
        else
          return
        end
      end
    end
  rescue IO::EAGAINWaitReadable
    # no-op
  end

  private

  # @return [void]
  def override_setting_by_step(setting_step)
    raw_data = output_report_generator.generate_by_step(setting_step)
    ProconBypassMan.logger.info "[procon_setting_overrider] >>> #{raw_data.unpack("H*").first}"
    output_report_watcher.mark_as_send(raw_data)
    send_procon(raw_data)
  end

  # @return [void]
  def re_override_setting_by_cmd(sub_command_with_arg)
    raw_data = output_report_generator.generate_by_sub_command_with_arg(sub_command_with_arg)
    ProconBypassMan.logger.info "[procon_setting_overrider] >>> #{raw_data.unpack("H*").first}"
    send_procon(raw_data)
  end

  def non_blocking_read_procon
    procon.non_blocking_read
  end

  def send_procon(raw_data)
    procon.send(raw_data)
  end
end
