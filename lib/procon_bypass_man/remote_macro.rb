module ProconBypassMan
  module RemoteMacro
    require "procon_bypass_man/remote_macro/remote_macro_object"
    require "procon_bypass_man/remote_macro/remote_macro_receiver"
    require "procon_bypass_man/remote_macro/remote_macro_sender"
    require "procon_bypass_man/remote_macro/queue_over_process"
    require "procon_bypass_man/remote_macro/task"
    require "procon_bypass_man/remote_macro/task_queue"

    ACTION_KEY = "remote_macro"

    TaskQueueInProcess = ProconBypassMan::RemoteMacro::TaskQueue.new
  end
end
