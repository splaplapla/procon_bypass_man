module ProconBypassMan
  class Watchdog
    def initialize(timeout: 100)
      @timeout = timeout
      active!
    end

    # @return [Boolean]
    def outdated?
      @time < Time.now
    end

    # @return [Time]
    def time
      @time
    end

    # @return [void]
    def active!
      @time = Time.now + @timeout
    end
  end
end
