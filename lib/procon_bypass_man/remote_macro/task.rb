# RemoteActionInBypassProcess
# NOTE: remote macroとpbm remote actionの両方で使う
class ProconBypassMan::RemoteMacro::Task < ::Struct.new(:name, :uuid, :steps, :type)
  TYPE_MACRO = 'macro'
  TYPE_PBM_ACTION = 'action'

  # remote actionのためのalias
  def action
    name
  end

  def args
    steps
  end
end
