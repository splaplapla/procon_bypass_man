module ProconBypassMan
  module RemoteAction
    module RemotePbmJob
      class StopPbmJob < BaseAction

        def action_content(_args)
          ProconBypassMan.logger.info "execute StopPbmJob!"
          Process.kill("TERM", ProconBypassMan.pid)
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
end
