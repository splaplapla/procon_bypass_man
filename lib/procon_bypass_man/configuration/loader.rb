module ProconBypassMan
  class Configuration
    module Loader
      def self.load(setting_path: )
        validation_instance = ProconBypassMan::Configuration.switch_context(:validation) do |instance|
          begin
            yaml = YAML.load_file(setting_path) or raise "読み込みに失敗しました"
            instance.instance_eval(yaml["setting"])
          rescue SyntaxError
            instance.errors[:base] << "Rubyのシンタックスエラーです"
            next(instance)
          rescue Psych::SyntaxError
            instance.errors[:base] << "yamlのシンタックスエラーです"
            next(instance)
          end
          instance.valid?
          next(instance)
        end

        if !validation_instance.errors.empty?
          raise ProconBypassMan::CouldNotLoadConfigError, validation_instance.errors
        end

        yaml = YAML.load_file(setting_path)
        ProconBypassMan::Configuration.instance.setting_path = setting_path
        ProconBypassMan::Configuration.instance.reset!
        ProconBypassMan.reset!

        case yaml["version"]
        when 1.0, nil
          ProconBypassMan::Configuration.instance.instance_eval(yaml["setting"])
        else
          ProconBypassMan.logger.warn "不明なバージョンです。failoverします"
          ProconBypassMan::Configuration.instance.instance_eval(yaml["setting"])
        end
        ProconBypassMan::Configuration.instance
      end

      def self.reload_setting
        self.load(setting_path: ProconBypassMan::Configuration.instance.setting_path)
      end
    end
  end
end
