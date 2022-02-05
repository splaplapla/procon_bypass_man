module ProconBypassMan
  module Plugin
    module Splatoon2
      module Macro
        module SokuwariForSplashBomb
          def self.display_name
            :sokuwari_for_splash_bomb
          end

          # procon_bypass_man: 0.1.18以上が必要
          def self.steps
            [ :toggle_r_for_0_2sec,
              :toggle_thumbr_for_0_14sec,
              :toggle_thumbr_and_toggle_zr_for_0_34sec,
              :toggle_r_for_1sec,
            ].freeze
          end
        end
      end
    end
  end
end
