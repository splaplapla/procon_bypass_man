module ProconBypassMan
  module ExternalInput
    module Channels
      class Base
        # @return [String, NilClass]
        def read
          raise NotImplementedError
        end

        def shutdown
          raise NotImplementedError
        end
      end
    end
  end
end
