module ProconBypassMan
  class ButtonsSettingConfiguration
    module Loader
      require 'digest/md5'

      # @return [ProconBypassMan::ButtonsSettingConfiguration]
      def self.load(setting_path: )
        ProconBypassMan::ButtonsSettingConfiguration.instance.setting_path = setting_path

        ProconBypassMan::ButtonsSettingConfiguration.switch_new_context(:validation) do |new_instance|
          yaml = YAML.load_file(setting_path) or raise "読み込みに失敗しました"
          new_instance.instance_eval(yaml["setting"])
          validator = Validator.new(new_instance)
          if validator.valid?
            next
          else
            raise ProconBypassMan::CouldNotLoadConfigError, validator.errors_to_s
          end
        rescue SyntaxError
          raise ProconBypassMan::CouldNotLoadConfigError, "Rubyスクリプトのシンタックスエラーです"
        rescue NoMethodError
          raise ProconBypassMan::CouldNotLoadConfigError, "Rubyスクリプトに未定義の定数・変数があります"
        rescue Psych::SyntaxError
          raise ProconBypassMan::CouldNotLoadConfigError, "yamlのシンタックスエラーです"
        end

        ProconBypassMan::ButtonsSettingConfiguration.instance.reset!
        ProconBypassMan.reset!

        yaml = YAML.load_file(setting_path)
        ProconBypassMan.config.raw_setting = yaml.dup
        case yaml["version"]
        when 1.0, nil
          ProconBypassMan::ButtonsSettingConfiguration.instance.instance_eval(yaml["setting"])
        else
          ProconBypassMan.logger.warn "不明なバージョンです。failoverします"
          ProconBypassMan::ButtonsSettingConfiguration.instance.instance_eval(yaml["setting"])
        end

        File.write(ProconBypassMan.digest_path, Digest::MD5.hexdigest(yaml["setting"]))

        ProconBypassMan::ButtonsSettingConfiguration.instance
      end

      def self.reload_setting
        self.load(setting_path: ProconBypassMan::ButtonsSettingConfiguration.instance.setting_path)
      end
    end
  end
end
