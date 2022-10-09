module ProconBypassMan
  module Plugin
    module Splatoon3
      module Macro
        module JumpToLeftKey
          def self.display_name
            :jump_to_left_key
          end

          def self.steps
            [:x, :x, :x, :left, :left, :left, :left, :left, :toggle_a_for_0_1sec, :wait_for_0_5sec]
          end

          def self.description
            '試合中に左キーに割り当てられている味方へのスーパージャンプ'
          end
        end
      end
    end
  end
end
