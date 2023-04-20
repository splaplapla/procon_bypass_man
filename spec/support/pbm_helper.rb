module PBMHelper
  def self.wait_until
    timer = ProconBypassMan::SafeTimeout.new(timeout: Time.now + 2)
    loop do
      raise 'timeout!!' if timer.timeout?
      break if yield
      sleep(0.3)
    end
  end
end
