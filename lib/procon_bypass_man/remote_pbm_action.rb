# frozen_string_literal: true

module ProconBypassMan
  module RemotePbmAction
    require "procon_bypass_man/remote_pbm_action/base_action"
    require "procon_bypass_man/remote_pbm_action/change_pbm_version_action"
    require "procon_bypass_man/remote_pbm_action/reboot_os_action"
    require "procon_bypass_man/remote_pbm_action/stop_pbm_action"
    require "procon_bypass_man/remote_pbm_action/restore_pbm_setting"
    require "procon_bypass_man/remote_pbm_action/report_procon_status"
    require "procon_bypass_man/remote_pbm_action/commands/update_remote_pbm_action_status_command"
    require "procon_bypass_man/remote_pbm_action/commands/run_remote_pbm_action_dispatch_command"
    require "procon_bypass_man/remote_pbm_action/value_objects/remote_pbm_action_object"

    ACTION_CHANGE_PBM_VERSION = "change_pbm_version"
    ACTION_REBOOT_OS = "reboot_os"
    ACTION_STOP_PBM = "stop_pbm"
    ACTION_RESTORE_SETTING = "restore_pbm_setting"
    ACTION_REPORT_PORCON_STATUS = 'report_porcon_status'

    ACTIONS_IN_MASTER_PROCESS = [
      ACTION_CHANGE_PBM_VERSION,
      ACTION_REBOOT_OS,
      ACTION_STOP_PBM,
      ACTION_RESTORE_SETTING,
    ]
    ACTIONS_IN_BYPASS_PROCESS = [
      ACTION_REPORT_PORCON_STATUS,
    ]
    ACTIONS = ACTIONS_IN_MASTER_PROCESS + ACTIONS_IN_BYPASS_PROCESS

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
