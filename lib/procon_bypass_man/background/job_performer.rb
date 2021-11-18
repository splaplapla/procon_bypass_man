module ProconBypassMan
  module Background
    class JobPerformer
      def initialize(klass: , args: )
        @klass = klass
        @args = args
      end

      def perform
        @klass.perform(*@args)
      rescue => e
        ProconBypassMan::ReportErrorJob.perform(e)
      end
    end
  end
end
