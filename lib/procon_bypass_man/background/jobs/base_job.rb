class ProconBypassMan::BaseJob
  extend ProconBypassMan::Background::JobPerformable

  # @return [Boolean]
  def self.re_enqueue_if_failed
    false
  end
end
