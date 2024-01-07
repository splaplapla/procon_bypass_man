require "procon_bypass_man/buttons_setting_configuration/param_normalizer"
require "procon_bypass_man/buttons_setting_configuration/metadata_loader"

module ProconBypassMan
  class ButtonsSettingConfiguration
    module Loader
      require 'digest/md5'

      # @return [ProconBypassMan::ButtonsSettingConfiguration]
      def self.load(setting_path: )
        metadata_loader = ProconBypassMan::ButtonsSettingConfiguration::MetadataLoader.load(setting_path: setting_path)
        if(Gem::Version.new(metadata_loader.required_pbm_version) >= Gem::Version.new(ProconBypassMan::VERSION))
          ProconBypassMan::SendErrorCommand.execute(error: '起動中のPBMが設定ファイルのバージョンを満たしていません。設定ファイルが意図した通り動かない可能性があります。PBMのバージョンをあげてください。')
        end

        ProconBypassMan::Procon.reset! # TODO: ここでresetするのは微妙な気がする

        new_instance, yaml =
          begin
            new_instance = ProconBypassMan::ButtonsSettingConfiguration.new
            new_instance.setting_path = setting_path
            yaml = ProconBypassMan::YamlLoader.load(path: setting_path)
            new_instance.instance_eval(yaml["setting"])
            validator = Validator.new(new_instance)
            if validator.valid?
              [new_instance, yaml]
            else
              fallback_setting_if_has_backup(current_setting_path: setting_path)
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

        ProconBypassMan.config.raw_setting = yaml
        ProconBypassMan.buttons_setting_configuration = new_instance
        File.write(ProconBypassMan.digest_path, Digest::MD5.hexdigest(yaml["setting"]))
        FileUtils.rm_rf(ProconBypassMan.fallback_setting_path) # NOTE: 設定ファイルの読み込みに成功したら、バックアップを削除する

        ProconBypassMan.buttons_setting_configuration
      end

      def self.reload_setting
        ProconBypassMan.ephemeral_config.reset!
        self.load(setting_path: ProconBypassMan.buttons_setting_configuration.setting_path)
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
