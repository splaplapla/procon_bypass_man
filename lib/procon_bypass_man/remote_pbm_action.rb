module ProconBypassMan
  module RemotePbmAction
    require "procon_bypass_man/remote_pbm_action/base_action"
    require "procon_bypass_man/remote_pbm_action/change_pbm_version_action"
    require "procon_bypass_man/remote_pbm_action/reboot_os_action"
    require "procon_bypass_man/remote_pbm_action/stop_pbm_action"
    require "procon_bypass_man/remote_pbm_action/lib/update_remote_pbm_action_status_command"

    ACTION_CHANGE_PBM_VERSION = "change_pbm_version"
    ACTION_REBOOT_OS = "reboot_os"
    ACTION_STOP_PBM = "stop_pbm"
    ACTION_RESTORE_SETTING = "restore_setting" # TODO

    ACTIONS = [
      ACTION_CHANGE_PBM_VERSION,
      ACTION_REBOOT_OS,
      ACTION_STOP_PBM,
      ACTION_RESTORE_SETTING,
    ]

    STATUS_FAILED = :failed
    STATUS_IN_PROGRESS = :in_progress
    STATUS_PROCESSED = :processed

    ACTION_STATUSES = [
      STATUS_FAILED,
      STATUS_IN_PROGRESS,
      STATUS_PROCESSED,
    ]
  end
end
