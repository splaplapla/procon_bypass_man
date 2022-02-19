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

          def self.description
            '試合中に右キーに割り当てられている味方へのスーパージャンプ'
          end
        end
      end
    end
  end
end
