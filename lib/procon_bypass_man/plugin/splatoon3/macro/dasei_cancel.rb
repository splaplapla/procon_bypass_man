module ProconBypassMan
  module Plugin
    module Splatoon3
      module Macro
        module DaseiCancel
          def self.display_name
            :dasei_cancel
          end

          def self.steps
            [:pressing_r_for_0_03sec, :pressing_r_and_pressing_zl_for_0_2sec].freeze
          end

          def self.descrition
            '惰性キャンセル'
          end
        end
      end
    end
  end
end

