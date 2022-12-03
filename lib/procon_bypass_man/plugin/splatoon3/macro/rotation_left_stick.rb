module ProconBypassMan
  module Plugin
    module Splatoon3
      module Macro
        module RotationLeftStick
          def self.display_name
            :rotation_left_stick
          end

          def self.steps
            [:rotation_left_stick]
          end

          def self.description
            '左スティックを1回転します'
          end
        end
      end
    end
  end
end
