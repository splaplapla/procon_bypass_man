module ProconBypassMan
  class SafeTimeout
    class Timeout < StandardError; end

    # 5秒後がタイムアウト
    def initialize(timeout: Time.now + 5)
      @timeout = timeout
    end

    # @raise [Timeout]
    def throw_if_timeout!
      raise Timeout if timeout?
    end

    # @return [Boolean]
    def timeout?
      @timeout < Time.now
    end
  end
end
