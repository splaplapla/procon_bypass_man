class ProconBypassMan::ProcessChecker
  # @param [integer] pid
  # @return [Boolean]
  def self.running?(pid)
    begin
      Process.kill(0, pid)
      true
    rescue Errno::ESRCH
      false
    rescue Errno::EPERM
      true
    end
  end
end
