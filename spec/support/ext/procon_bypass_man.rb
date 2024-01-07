module ProconBypassMan
  def self.buttons_setting_configure(setting_path: nil, &block)
    if block_given?
      ProconBypassMan.buttons_setting_configuration.instance_eval(&block)
    else
      ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting_path)
    end
  end

  def self.reset!
    ProconBypassMan::Procon.reset!
    self.buttons_setting_configuration = nil
    ProconBypassMan.ephemeral_config.reset!
  end
end
