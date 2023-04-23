module ProconBypassMan
  module ExternalInput
    module Channels
      class Base
        # @return [String, NilClass]
        def read
          raise NotImplementedError
        end

        # @return [void]
        def shutdown
          raise NotImplementedError
        end

        # @return [String]
        def display_name_for_boot_message
          raise NotImplementedError
        end
      end
    end
  end
end
