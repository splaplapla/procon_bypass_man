require "procon_bypass_man/remote_pbm_action/change_pbm_version_action"
require "procon_bypass_man/remote_pbm_action/reboot_os_action"
require "procon_bypass_man/remote_pbm_action/reboot_os_pbm"

module ProconBypassMan
  module RemotePbmAction
    CHANGE_PBM_VERSION = "change_pbm_version"
    REBOOT_PBM = "reboot_pbm"
    REBOOT_OS = "reboot_os"

    ACTIONS = [
      CHANGE_PBM_VERSION,
      REBOOT_PBM,
      REBOOT_OS,
    ]
  end
end
