module ProconBypassMan
  module Plugin
    module Splatoon2
      module Macro
        module JumpToUpKey
          def self.display_name
            :jump_to_up_key
          end

          def self.steps
            [:x, :up, :a, :a].freeze
          end

          def self.description
            '試合中に上キーに割り当てられている味方へのスーパージャンプ'
          end
        end
      end
    end
  end
end
