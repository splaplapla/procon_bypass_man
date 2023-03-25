module ProconBypassMan
  module ExternalInput
    module Channels
      class Base
        # @return [SerialPort]
        def read
          raise NotImplementedError
        end
      end
    end
  end
end
