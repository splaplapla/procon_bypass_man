class ProconBypassMan::RemoteAction::RemoteActionObject
  # valueobjectがvalidatorの責務も持っている. 今度分離する
  class ValidationError < StandardError; end
  class MustBeNotNilError < ValidationError; end
  class NonSupportAction < ValidationError; end

  attr_accessor :name, :uuid, :steps

  # @param [String] name
  # @param [String] uuid
  # @param [Array] steps
  def initialize(name: , uuid:, steps: )
    @name = name
    @uuid = uuid
    @steps = steps
    freeze
  end

  # @raise [MustBeNotNilError]
  # @raise [NonSupportAction]
  # @return [void]
  def validate!
    self.uuid or raise MustBeNotNilError, "uuidは値が必須です"
    unless self.steps.is_a?(Array)
      raise ValidationError, "stepsは配列です"
    end
  end
end
