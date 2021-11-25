module ProconBypassMan
  class RemotePbmActionObject
    # valueobjectがvalidatorの責務も持っている. 今度分離する
    class MustBeNotNilError < StandardError; end

    attr_accessor :action, :status, :uuid, :created_at

    def initialize(action: , status:, uuid:, created_at:)
      self.action = action or raise MustBeNotNilError, "actionは値が必須です"
      self.status = status or raise MustBeNotNilError, "statusは値が必須です"
      self.uuid = uuid or raise MustBeNotNilError, "uuidは値が必須です"
      self.created_at = created_at

      freeze
    end
  end
end
