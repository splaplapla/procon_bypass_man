module ProconBypassMan
  module Plugin
    module Splatoon2
      module Macro
        module JumpToRightKey
          def self.display_name
            :jump_to_right_key
          end

          def self.steps
            [:x, :right, :a, :a].freeze
          end
        end
      end
    end
  end
end
