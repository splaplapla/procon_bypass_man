module ProconBypassMan
  module RemotePbmAction
    class RestorePbmSettingAction < BaseAction

      def action_content(args: )
        require "pbmenv"
        ProconBypassMan.logger.info "execute RestorePbmSettingAction!"
        setting = args["setting"] or raise(ProconBypassMan::RemotePbmAction::NeedPbmVersionError, "settingが必要です, #{args.inspect}")
        File.write(
          ProconBypassMan::ButtonsSettingConfiguration.instance.setting_path,
          setting,
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

