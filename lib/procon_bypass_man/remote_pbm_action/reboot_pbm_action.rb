module ProconBypassMan
  module RemotePbmAction
    class ActionUnexpectedError < StandardError; end

    class RebootPbmAction < BaseAction
      def self.execute!
      end
    end
  end
end
