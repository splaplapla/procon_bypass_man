module ProconBypassMan
  class RemoteMacroObject
    # valueobjectがvalidatorの責務も持っている. 今度分離する
    class ValidationError < StandardError; end
    class MustBeNotNilError < ValidationError; end
    class NonSupportAction < ValidationError; end

    attr_accessor :action, :status, :uuid, :created_at, :job_args

    # @param [String] action
    # @param [String] status
    # @param [String] #uuid
    # @param [Time] created_at
    # @return [Hash] job_args
    def initialize(action: , uuid:, job_args: )
      @action = action
      @uuid = uuid
      @job_args = job_args
      freeze
    end

    # @raise [MustBeNotNilError]
    # @raise [NonSupportAction]
    # @return [void]
    def validate!
    end
  end
end
