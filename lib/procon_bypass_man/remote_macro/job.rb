module ProconBypassMan
  module RemoteMacro
    class Job < Struct.new(:action, :uuid, :steps)
    end
  end
end
