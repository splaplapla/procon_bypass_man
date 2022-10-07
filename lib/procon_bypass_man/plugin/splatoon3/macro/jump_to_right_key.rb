module ProconBypassMan
  module Plugin
    module Splatoon3
      module Macro
        module JumpToRightKey
          def self.display_name
            :jump_to_right_key
          end

          def self.steps
            [:x, :x, :x, :right, :right, :right, :right, :right, :toggle_a_for_0_1sec, :wait_for_0_5sec]
          end

          def self.description
            '試合中に右キーに割り当てられている味方へのスーパージャンプ'
          end
        end
      end
    end
  end
end
