# frozen_string_literal: true

module ProconBypassMan
  module RemoteAction
    # NOTE: RemoteActionは「具体的な処理を行うジョブ」と「マクロ」を内包する
    require "procon_bypass_man/remote_action/remote_pbm_job"

    require "procon_bypass_man/remote_action/remote_action_object"
    require "procon_bypass_man/remote_action/remote_action_receiver"
    require "procon_bypass_man/remote_action/remote_action_sender"
    require "procon_bypass_man/remote_action/queue_over_process"
    require "procon_bypass_man/remote_action/task"
    require "procon_bypass_man/remote_action/task_queue"

    ACTION_MACRO = "remote_macro"

    TaskQueueInProcess = ProconBypassMan::RemoteAction::TaskQueue.new
  end
end
