module ProconBypassMan
  module RemoteAction
    module RemotePbmJob
      class RestorePbmSettingAction < BaseAction

        def action_content(args: )
          require "pbmenv"
          ProconBypassMan.logger.info "execute RestorePbmSettingAction!"
          setting = args.dig("setting") or raise(ProconBypassMan::RemotePbmJob::NeedPbmVersionError, "settingが必要です, #{args.inspect}")

          # 復元に失敗したら戻せるように退避する
          FileUtils.copy(
            ProconBypassMan.buttons_setting_configuration.setting_path,
            ProconBypassMan.fallback_setting_path,
          )

          ProconBypassMan::YamlWriter.write(
            path: ProconBypassMan.buttons_setting_configuration.setting_path,
            content: setting,
          )

          hot_reload!
        end

        private

        def before_action_callback
          be_in_progress
        end

        def after_action_callback
          be_processed
        end

        # @return [void]
        def hot_reload!
          Process.kill(:USR2, ProconBypassMan.pid)
        end
      end
    end
  end
end
