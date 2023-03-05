# frozen_string_literal: true

# FIXME: RemotePbmActionInBypassProcessという名前にする
module ProconBypassMan
  module RemoteAction
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
