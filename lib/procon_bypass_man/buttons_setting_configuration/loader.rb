require "procon_bypass_man/buttons_setting_configuration/param_normalizer"
require "procon_bypass_man/buttons_setting_configuration/metadata_loader"

module ProconBypassMan
  class ButtonsSettingConfiguration
    module Loader
      require 'digest/md5'

      # @return [ProconBypassMan::ButtonsSettingConfiguration]
      def self.load(setting_path: )
        ProconBypassMan::ButtonsSettingConfiguration.instance.setting_path = setting_path

        metadata_loader = ProconBypassMan::ButtonsSettingConfiguration::MetadataLoader.load(setting_path: setting_path)
        if(Gem::Version.new(metadata_loader.required_pbm_version) >= Gem::Version.new(ProconBypassMan::VERSION))
          ProconBypassMan::SendErrorCommand.execute(error: '起動中のPBMが設定ファイルのバージョンを満たしていません。設定ファイルが意図した通り動かない可能性があります。PBMのバージョンをあげてください。')
        end

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
          fallback_setting_if_has_backup(current_setting_path: setting_path)
          raise ProconBypassMan::CouldNotLoadConfigError, "Rubyスクリプトのシンタックスエラーです"
        rescue NameError
          fallback_setting_if_has_backup(current_setting_path: setting_path)
          raise ProconBypassMan::CouldNotLoadConfigError, "Rubyスクリプトに未定義の定数・変数があります"
        rescue Psych::SyntaxError
          fallback_setting_if_has_backup(current_setting_path: setting_path)
          raise ProconBypassMan::CouldNotLoadConfigError, "yamlのシンタックスエラーです"
        end

        ProconBypassMan::ButtonsSettingConfiguration.instance.reset!
        ProconBypassMan.reset!

        yaml = ProconBypassMan::YamlLoader.load(path: setting_path)
        ProconBypassMan.config.raw_setting = yaml.dup
        case yaml["version"]
        when 1.0, nil
          ProconBypassMan::ButtonsSettingConfiguration.instance.instance_eval(yaml["setting"])
        else
          ProconBypassMan.logger.warn "不明なバージョンです。failoverします"
          ProconBypassMan::ButtonsSettingConfiguration.instance.instance_eval(yaml["setting"])
        end

        File.write(ProconBypassMan.digest_path, Digest::MD5.hexdigest(yaml["setting"]))

        if File.exist?(ProconBypassMan.fallback_setting_path)
          FileUtils.rm_rf(ProconBypassMan.fallback_setting_path)
        end

        ProconBypassMan::ButtonsSettingConfiguration.instance
      end

      def self.reload_setting
        ProconBypassMan.ephemeral_config.reset!
        self.load(setting_path: ProconBypassMan::ButtonsSettingConfiguration.instance.setting_path)
      end

      def self.fallback_setting_if_has_backup(current_setting_path: )
        return unless File.exist?(ProconBypassMan.fallback_setting_path)
        return if current_setting_path.nil?

        FileUtils.copy(
          ProconBypassMan.fallback_setting_path,
          current_setting_path,
        )
        FileUtils.rm_rf(ProconBypassMan.fallback_setting_path)
      end
    end
  end
end
