require "procon_bypass_man/buttons_setting_configuration/param_normalizer/button_list"
require "procon_bypass_man/buttons_setting_configuration/param_normalizer/force_neutral"

module ProconBypassMan
  class ButtonsSettingConfiguration
    module ParamNormalizer
      class UnSupportValueError < StandardError; end
      class UnexpectedValueError < StandardError; end
    end
  end
end
