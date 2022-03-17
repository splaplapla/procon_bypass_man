module ProconBypassMan
  module RemoteMacro
    class TaskQueue < ::Queue
      def present?
        not empty?
      end

      def non_blocking_pop
        present? && pop
      end
    end
  end
end
