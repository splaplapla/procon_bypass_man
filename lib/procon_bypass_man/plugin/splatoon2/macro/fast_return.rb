module ProconBypassMan
  module Plugin
    module Splatoon2
      module Macro
        module FastReturn
          def self.display_name
            :fast_return
          end

          def self.steps
            [:x, :down, :a, :a].freeze
          end

          def self.description
            '試合中にリスポーンにスーパージャンプ'
          end
        end
      end
    end
  end
end
