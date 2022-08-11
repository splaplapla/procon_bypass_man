module ProconBypassMan
  module Background
    class JobPerformer
      def initialize(klass: , args: )
        @klass = klass
        @args = args
      end

      # @raise [any]
      def perform
        @klass.perform(*@args)
      end
    end
  end
end
