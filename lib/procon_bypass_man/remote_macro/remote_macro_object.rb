module ProconBypassMan
  class RemoteMacroObject
    # valueobjectがvalidatorの責務も持っている. 今度分離する
    class ValidationError < StandardError; end
    class MustBeNotNilError < ValidationError; end
    class NonSupportAction < ValidationError; end

    attr_accessor :action, :uuid, :steps

    # @param [String] action
    # @param [String] uuid
    # @param [Array] steps
    def initialize(action: , uuid:, steps: )
      @action = action
      @uuid = uuid
      @steps = steps
      freeze
    end

    # @raise [MustBeNotNilError]
    # @raise [NonSupportAction]
    # @return [void]
    def validate!
      self.action or raise MustBeNotNilError, "actionは値が必須です"
      self.uuid or raise MustBeNotNilError, "uuidは値が必須です"
      unless self.steps.is_a?(Array)
        raise ValidationError, "stepsは配列です"
      end
    end
  end
end
