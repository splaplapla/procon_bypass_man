module ProconBypassMan
  module Plugin
    module Splatoon3
      module Macro
        module FastReturn
          def self.display_name
            :fast_return
          end

          def self.steps
            [:x, :x, :x, :down, :down, :down, :down, :down, :toggle_a_for_0_1sec, :wait_for_0_5sec]
          end

          def self.description
            '試合中にリスポーンにスーパージャンプ'
          end
        end
      end
    end
  end
end
