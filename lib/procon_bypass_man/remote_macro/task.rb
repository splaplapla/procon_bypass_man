module ProconBypassMan
  module RemoteMacro
    class Task < Struct.new(:action, :uuid, :steps)
    end
  end
end
