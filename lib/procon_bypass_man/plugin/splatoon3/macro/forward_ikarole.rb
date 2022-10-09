module ProconBypassMan
  module Plugin
    module Splatoon3
      module Macro
        module ForwardIkarole
          def self.display_name
            :forward_ikarole
          end

          def self.steps
            [:forward_ikarole1].freeze
          end

          def self.description
            '前方にイカロールをします'
          end
        end
      end
    end
  end
end
