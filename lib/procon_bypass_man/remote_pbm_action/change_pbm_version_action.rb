module ProconBypassMan
  module RemotePbmAction
    class ChangePbmVersionAction < BaseAction

      def action_content(args: )
        require "pbmenv"
        ProconBypassMan.logger.info "execute ChangePbmVersionAction!"
        pbm_version = args["pbm_version"] or raise(ProconBypassMan::RemotePbmAction::NeedPbmVersionError, "pbm_versionが必要です, #{args.inspect}")
        Pbmenv.uninstall(pbm_version) # 途中でシャットダウンしてしまった、とか状態が途中の状態かもしれないので一旦消す
        Pbmenv.install(pbm_version, enable_pbm_cloud: true)
        Pbmenv.use(pbm_version)
        Pbmenv.clean(10)
        ProconBypassMan.logger.info "#{pbm_version}へアップグレードしました"
        ProconBypassMan::ReportCompletedUpgradePbmJob.perform
        `reboot` # symlinkの参照先が変わるのでrebootする必要がある
      end

      private

      def before_action_callback
        be_processed
      end

      def after_action_callback
        # no-op
      end
    end
  end
end
