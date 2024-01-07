module ProconBypassMan
  def self.buttons_setting_configure(setting_path: nil, &block)
    if block_given?
      ProconBypassMan.buttons_setting_configuration.instance_eval(&block)
    else
      ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting_path)
    end
  end
end
