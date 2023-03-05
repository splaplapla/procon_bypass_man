module ProconBypassMan
  class RemotePbmJobObject
    # valueobjectがvalidatorの責務も持っている. 今度分離する
    class ValidationError < StandardError; end
    class MustBeNotNilError < ValidationError; end
    class NonSupportAction < ValidationError; end

    attr_accessor :action, :status, :uuid, :created_at, :job_args

    # @param [String] action
    # @param [String] status
    # @param [String] #uuid
    # @param [Time] created_at
    # @param [Hash] job_args
    def initialize(action: , status:, uuid:, created_at:, job_args: )
      self.action = action
      self.status = status
      self.uuid = uuid
      self.created_at = created_at
      self.job_args = job_args

      freeze
    end

    # @raise [MustBeNotNilError]
    # @raise [NonSupportAction]
    # @return [void]
    def validate!
      self.action or raise MustBeNotNilError, "actionは値が必須です"
      self.status or raise MustBeNotNilError, "statusは値が必須です"
      self.uuid or raise MustBeNotNilError, "uuidは値が必須です"

      unless ProconBypassMan::RemoteAction::RemotePbmJob::ACTIONS.include?(action)
        raise NonSupportAction, "知らないアクションです"
      end
    end
  end
end
