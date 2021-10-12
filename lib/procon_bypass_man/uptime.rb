require "time"

module ProconBypassMan
  class Uptime
    def self.from_boot
      boot_time = Time.parse(`uptime -s`.chomp).to_i
      return Time.now.to_i - boot_time.to_i
    rescue => e
      ProconBypassMan.logger.error(e)
      return -1
    end
  end
end
