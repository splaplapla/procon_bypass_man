require "procon_bypass_man/buttons_setting_configuration/param_normalizer/button_list"
require "procon_bypass_man/buttons_setting_configuration/param_normalizer/button"
require "procon_bypass_man/buttons_setting_configuration/param_normalizer/force_neutral"
require "procon_bypass_man/buttons_setting_configuration/param_normalizer/if_pressed_allows_nil"
require "procon_bypass_man/buttons_setting_configuration/param_normalizer/flip_if_pressed"
require "procon_bypass_man/buttons_setting_configuration/param_normalizer/disable_macro_if_pressed"
require "procon_bypass_man/buttons_setting_configuration/param_normalizer/if_pressed"
require "procon_bypass_man/buttons_setting_configuration/param_normalizer/open_macro_steps"

module ProconBypassMan
  class ButtonsSettingConfiguration
    module ParamNormalizer
      class UnSupportValueError < StandardError; end
      class UnexpectedValueError < UnSupportValueError; end
    end
  end
end
