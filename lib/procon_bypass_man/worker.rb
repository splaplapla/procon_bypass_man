module ProconBypassMan
  class Worker
    attr_accessor :pid

    # @param [Numeric] child pid
    def self.run_with_fork
      pid = Kernel.fork do
        ProconBypassMan.after_fork_on_worker_process
        ProconBypassMan::Background::WorkerProcess.run # blocking
      end

      new(pid: pid)
    end

    def initialize(pid: )
      @pid = pid
      write_pid_file(pid: pid)
    end

    def shutdown
      begin
        Process.kill("TERM", ProconBypassMan.worker_pid)
      rescue Errno::ESRCH
        # no-op
      end
      FileUtils.rm_rf(ProconBypassMan.worker_pid_path)
    end

    private

    def write_pid_file(pid: )
      File.write(ProconBypassMan.worker_pid_path, pid)
    end
  end
end
