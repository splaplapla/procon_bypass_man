module ProconBypassMan
  module RemotePbmAction
    class RestorePbmSettingAction < BaseAction

      def action_content(args: )
        require "pbmenv"
        ProconBypassMan.logger.info "execute RestorePbmSettingAction!"
        setting = args.dig("setting") or raise(ProconBypassMan::RemotePbmAction::NeedPbmVersionError, "settingが必要です, #{args.inspect}")

        # 復元に失敗したら戻せるように退避する
        FileUtils.copy(
          ProconBypassMan::ButtonsSettingConfiguration.instance.setting_path,
          ProconBypassMan.fallback_setting_path,
        )

        ProconBypassMan::YamlWriter.write(
          path: ProconBypassMan::ButtonsSettingConfiguration.instance.setting_path,
          content: setting,
        )
        ProconBypassMan.hot_reload!
      end

      private

      def before_action_callback
        be_in_progress
      end

      def after_action_callback
        be_processed
      end
    end
  end
end

