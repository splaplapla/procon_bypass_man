module ProconBypassMan
  module RemotePbmAction
    class ActionUnexpectedError < StandardError; end

    class BaseAction
      attr_accessor :pbm_job_uuid

      def initialize(pbm_job_uuid: )
        self.pbm_job_uuid = pbm_job_uuid
      end

      def action_content
        raise NotImplementedError, nil
      end

      def run!
        before_action_callback
        action_content
        after_action_callback
      rescue
        be_failed
      end

      def before_action_callback; end
      def after_action_callback; end

      def be_failed
        ProconBypassMan::UpdateRemotePbmActionCommand.new(pbm_job_uuid: pbm_job_uuid).execute(to_status: :failed)
      end

      def be_in_progress
        ProconBypassMan::UpdateRemotePbmActionCommand.new(pbm_job_uuid: pbm_job_uuid).execute(to_status: :in_progress)
      end

      def be_processed
        ProconBypassMan::UpdateRemotePbmActionCommand.new(pbm_job_uuid: pbm_job_uuid).execute(to_status: :processed)
      end
    end
  end
end
