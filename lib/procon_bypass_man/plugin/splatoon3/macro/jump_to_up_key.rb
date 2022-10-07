module ProconBypassMan
  module Plugin
    module Splatoon3
      module Macro
        module JumpToUpKey
          def self.display_name
            :jump_to_up_key
          end

          def self.steps
            [:x, :x, :x, :up, :up, :up, :up, :up, :toggle_a_for_0_1sec, :wait_for_0_5sec]
          end

          def self.description
            '試合中に上キーに割り当てられている味方へのスーパージャンプ'
          end
        end
      end
    end
  end
end
