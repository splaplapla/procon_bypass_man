# NOTE: remote macroとpbm remote actionの両方で使う
class ProconBypassMan::RemoteAction::Task < ::Struct.new(:name, :uuid, :steps, :type)
  TYPE_MACRO = 'macro'
  TYPE_ACTION = 'action'

  # remote actionのためのalias
  def action
    name
  end

  def job_args
    steps
  end
end
