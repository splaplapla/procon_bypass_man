class ProconBypassMan::DeviceConnection::ProconSettingOverrider
  attr_accessor :procon, :output_report_watcher, :output_report_generator

  SUB_COMMAND_HOME_LED_ON = "38"

  SUB_COMMAND_ARG_HOME_LED_ON = "1FF0FF"

  ALL_SETTINGS = {
    home_led_on: [SUB_COMMAND_HOME_LED_ON, SUB_COMMAND_ARG_HOME_LED_ON],
  }

  # TODO 自動生成する
  SPECIAL_SUB_COMMAND_ARGS =  {
    SUB_COMMAND_HOME_LED_ON => SUB_COMMAND_ARG_HOME_LED_ON,
  }

  def initialize(procon: )
    use_steps = {}
    if ProconBypassMan.config.enable_home_led_on_connect
      use_steps.merge!(home_led_on: ALL_SETTINGS[:home_led_on])
    end

    @setting_steps = use_steps.keys
    self.procon = ProconBypassMan::DeviceModel.new(procon)
    self.output_report_watcher = ProconBypassMan::DeviceConnection::SpoofingOutputReportWatcher.new(expected_sub_commands: use_steps.values)
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
    begin
      raw_data = non_blocking_read_procon
    rescue IO::EAGAINWaitReadable
      return
    end

    ProconBypassMan.logger.info "[procon_setting_overrider] <<< #{raw_data.unpack("H*").first}"
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
