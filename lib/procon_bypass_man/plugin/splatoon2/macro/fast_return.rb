module ProconBypassMan
  module Plugin
    module Splatoon2
      module Macro
        module FastReturn
          def self.name
            :fast_return
          end

          def self.steps
            [:x, :down, :a, :a].freeze
          end
        end
      end
    end
  end
end
