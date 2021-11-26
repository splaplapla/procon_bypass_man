module ProconBypassMan
  module RemotePbmAction
    class BaseAction
      def self.execute!
        raise NotImplementedError, nil
      end
    end
  end
end
