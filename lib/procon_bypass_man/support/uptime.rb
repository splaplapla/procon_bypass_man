require "time"

module ProconBypassMan
  class Uptime
    # @return [Integer]
    def self.from_boot
      new(uptime_cmd_result: `uptime -s`.chomp).from_boot
    end

    # @param [String] uptime_cmd_result
    def initialize(uptime_cmd_result: )
      @result = uptime_cmd_result
    end

    # @return [Integer]
    def from_boot
      return -1 if @result == '' # darwin系だとsオプションが使えない
      boot_time = Time.parse(@result).to_i
      return Time.now.to_i - boot_time.to_i
    rescue => e
      ProconBypassMan.logger.error(e)
      return -1
    end
  end
end
