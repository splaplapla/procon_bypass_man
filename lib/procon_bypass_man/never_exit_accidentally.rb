module ProconBypassMan
  module NeverExitAccidentally
    def exit_if_allow(status)
      if ProconBypassMan.never_exit_accidentally
        eternal_sleep
      else
        exit(status)
      end
    end
  end
end
