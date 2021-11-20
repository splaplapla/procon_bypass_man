module ProconBypassMan
  class Timer
    class Timeout < StandardError; end

    # 5秒後がタイムアウト
    def initialize(timeout: Time.now + 5)
      @timeout = timeout
    end

    def throw_if_timeout!
      raise Timeout if @timeout < Time.now
    end
  end
end
