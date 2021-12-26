# https://github.com/eventmachine/eventmachine/pull/929 is not released yet.
# i will delete this patch if released.
module EventMachine
  # @private
  class Reactor
    def run_timers
      timers_to_delete = []
      @timers.each {|t|
        if t.first <= @current_loop_time
          #@timers.delete t
          timers_to_delete << t
          EventMachine::event_callback "", TimerFired, t.last
        else
          break
        end
      }
      timers_to_delete.map{|c| @timers.delete c}
      timers_to_delete = nil
      #while @timers.length > 0 and @timers.first.first <= now
      #  t = @timers.shift
      #  EventMachine::event_callback "", TimerFired, t.last
      #end
    end
  end
end
