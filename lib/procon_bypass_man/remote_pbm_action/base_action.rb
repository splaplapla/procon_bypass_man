module ProconBypassMan
  module RemotePbmAction
    class ActionUnexpectedError < StandardError; end

    class BaseAction
      attr_accessor :pbm_job_uuid

      # @param [String] pbm_job_uuid
      def initialize(pbm_job_uuid: )
        self.pbm_job_uuid = pbm_job_uuid
      end

      def action_content
        raise NotImplementedError, nil
      end

      # @return [void]
      def run!
        before_action_callback
        action_content
        after_action_callback
      rescue => e
        be_failed
        ProconBypassMan::SendErrorCommand.execute(error: e)
      end

      def before_action_callback; end
      def after_action_callback; end

      def be_failed
        ProconBypassMan::UpdateRemotePbmActionStatusCommand.new(pbm_job_uuid: pbm_job_uuid).execute(to_status: :failed)
      end

      def be_in_progress
        ProconBypassMan::UpdateRemotePbmActionStatusCommand.new(pbm_job_uuid: pbm_job_uuid).execute(to_status: :in_progress)
      end

      def be_processed
        ProconBypassMan::UpdateRemotePbmActionStatusCommand.new(pbm_job_uuid: pbm_job_uuid).execute(to_status: :processed)
      end
    end
  end
end
