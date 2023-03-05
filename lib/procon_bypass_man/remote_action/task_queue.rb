class ProconBypassMan::RemoteAction::TaskQueue < ::Queue
  def present?
    not empty?
  end

  def non_blocking_shift
    present? && shift
  end
end
