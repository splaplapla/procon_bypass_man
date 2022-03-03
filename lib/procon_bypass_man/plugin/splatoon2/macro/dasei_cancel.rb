module ProconBypassMan
  module Plugin
    module Splatoon2
      module Macro
        module DaseiCancel
          def self.display_name
            :dasei_cancel
          end

          def self.steps
            [:pressing_r_for_0_03sec, :pressing_r_and_pressing_zl_for_0_2sec].freeze
          end

          def self.description
            '惰性キャンセル'
          end
        end
      end
    end
  end
end
