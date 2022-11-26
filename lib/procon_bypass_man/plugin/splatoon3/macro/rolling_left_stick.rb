module ProconBypassMan
  module Plugin
    module Splatoon3
      module Macro
        module RollingLeftStick
          def self.display_name
            :rolling_left_stick
          end

          def self.steps
            [:rolling_left_stick]
          end

          def self.description
            '左スティックを1回転します'
          end
        end
      end
    end
  end
end
