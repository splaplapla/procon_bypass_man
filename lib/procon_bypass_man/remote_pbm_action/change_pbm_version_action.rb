module ProconBypassMan
  module RemotePbmAction
    class ChangePbmVersionAction < BaseAction

      def action_content(args)
        require "pbmenv"
        ProconBypassMan.logger.info "execute ChangePbmVersionAction!"
        pbm_version = args["pbm_version"] or raise(ProconBypassMan::RemotePbmAction::NeedPbmVersionError, "pbm_versionが必要です, #{args.inspect}")
        Pbmenv.install(pbm_version)
        Pbmenv.use(pbm_version)
        `reboot` # symlinkの参照先が変わるのでrebootする必要がある
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
