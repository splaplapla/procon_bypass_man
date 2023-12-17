module ProconBypassMan
  class ReniceCommand
    def self.change_priority(to: , pid: )
      cmd =
        case to
        when :high
          "renice -n -20 -p #{pid}"
        when :low
          "renice -n 20 -p #{pid}"
        else
          raise "unknown priority"
        end
      ProconBypassMan.logger.debug { "[SHELL] #{cmd}" }
      `sudo #{cmd}`
    end
  end
end
