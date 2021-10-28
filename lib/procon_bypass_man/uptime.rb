require "time"

module ProconBypassMan
  class Uptime
    def self.from_boot
      result = `uptime -s`.chomp
      return -1 if result == '' # darwin系だとsオプションが使えない
      boot_time = result.to_i
      return Time.now.to_i - boot_time.to_i
    rescue => e
      ProconBypassMan.logger.error(e)
      return -1
    end
  end
end
