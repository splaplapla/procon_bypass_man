module ProconBypassMan
  module RemoteMacro
    class TaskQueue < ::Queue
      def present?
        not empty?
      end
    end
  end
end
