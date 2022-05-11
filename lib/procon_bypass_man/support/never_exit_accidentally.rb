module ProconBypassMan
  module NeverExitAccidentally
    def self.exit_if_allow_at_config
      if ProconBypassMan.never_exit_accidentally
        ProconBypassMan.eternal_sleep
      else
        yield if block_given?
        exit 1
      end
    end
  end
end
