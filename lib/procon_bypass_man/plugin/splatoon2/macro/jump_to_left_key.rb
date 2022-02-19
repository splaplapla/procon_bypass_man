module ProconBypassMan
  module Plugin
    module Splatoon2
      module Macro
        module JumpToLeftKey
          def self.display_name
            :jump_to_left_key
          end

          def self.steps
            [:x, :left, :a, :a].freeze
          end

          def self.description
            '試合中に左キーに割り当てられている味方へのスーパージャンプ'
          end
        end
      end
    end
  end
end
