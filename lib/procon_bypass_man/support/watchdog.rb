module ProconBypassMan
  class Watchdog
    def initialize
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
      @time = Time.now + 100
    end
  end
end
