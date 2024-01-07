require "spec_helper"

describe ProconBypassMan::ButtonsSettingConfiguration do
  before(:each) do
    # TODO: 全体のbefore(:each)に移動するべきでは？
    ProconBypassMan.reset!
  end

  let(:setting) { Setting.new(setting_content).to_file }

  describe 'Loader' do
    describe '.load' do
      context 'with enable' do
        context 'enableの引数に想定していないキーを与えるとき' do
          let(:setting_content) do
            <<~EOH
              version: 1.0
              setting: |-
                enable(:hogehoge)

                prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
            EOH
          end

          it 'エラーにならない' do
            ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
            expect(ProconBypassMan.ephemeral_config.enable_rumble_on_layer_change).to eq(nil)
            expect(ProconBypassMan.ephemeral_config.recognized_procon_color).to eq(nil)
          end
        end

        context '想定しているキーを与えるとき' do
          let(:setting_content) do
            <<~EOH
              version: 1.0
              setting: |-
                enable(:rumble_on_layer_change)

                prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
            EOH
          end

          it 'ProconBypassMan.ephemeral_config.enable_rumble_on_layer_changeに値をセットすること' do
            ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
            expect(ProconBypassMan.ephemeral_config.enable_rumble_on_layer_change).to eq(true)
          end
        end

        context 'enable(:procon_color, :red)が書いているとき' do
          let(:setting_content) do
            <<~EOH
              version: 1.0
              setting: |-
                enable(:procon_color, :red)

                prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
            EOH
          end

          it 'ProconBypassMan.ephemeral_config.recognized_procon_colorに:redが設定されること' do
            ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
            expect(ProconBypassMan.ephemeral_config.recognized_procon_color.name).to eq(:red)
          end
        end

        context 'enable(:procon_color, :not_found)が書いているとき' do
          let(:setting_content) do
            <<~EOH
              version: 1.0
              setting: |-
                enable(:procon_color, :not_found)

                prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
            EOH
          end

          it 'ProconBypassMan.ephemeral_config.recognized_procon_colorに:redが設定されること' do
            ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
            expect(ProconBypassMan.ephemeral_config.recognized_procon_color).to eq(nil)
          end
        end

        context 'enableを複数書くとき' do
          let(:setting_content) do
            <<~EOH
              version: 1.0
              setting: |-
                enable(:procon_color, :blue)
                enable(:rumble_on_layer_change)

                prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
            EOH
          end

          it 'それぞれの値を保存すること' do
            ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
            expect(ProconBypassMan.ephemeral_config.enable_rumble_on_layer_change).to eq(true)
            expect(ProconBypassMan.ephemeral_config.recognized_procon_color.name).to eq(:blue)
          end
        end
      end

      context 'with neutral_position' do
        let(:setting_content) do
          <<~EOH
            version: 1.0
            setting: |-
              prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
              set_neutral_position 1000, 1000
          EOH
        end
        it do
          ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
          expect(ProconBypassMan.buttons_setting_configuration.neutral_position.x).to eq(1000)
          expect(ProconBypassMan.buttons_setting_configuration.neutral_position.y).to eq(1000)
        end
        it do
          ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
          expect(ProconBypassMan.config.raw_setting).to be_a(Hash)
        end
      end
      context 'with left_analog_stick_cap' do
        context 'with force_neutral' do
          let(:setting_content) do
            <<~EOH
          version: 1.0
          setting: |-
            prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
            layer :up do
              left_analog_stick_cap cap: 1000, if_pressed: [:a], force_neutral: [:a]
            end
            EOH
          end
          it do
            ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
            expect(ProconBypassMan.buttons_setting_configuration.layers[:up].left_analog_stick_caps).to eq([
              {:cap=>1000, :force_neutral=> [:a], if_pressed: [:a] }
            ])
          end
        end
        context 'with force_neutral' do
          let(:setting_content) do
            <<~EOH
          version: 1.0
          setting: |-
            prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
            layer :up do
              left_analog_stick_cap cap: 1000, if_pressed: [:a], force_neutral: [:a], combined_press_is_pressed: [:b]
            end
            EOH
          end
          it do
            ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
            expect(ProconBypassMan.buttons_setting_configuration.layers[:up].left_analog_stick_caps).to eq([
              {:cap=>1000, :force_neutral=> [:a], if_pressed: [:a], combined_press_is_pressed: [:b] }
            ])
          end
        end
        context 'provide array' do
          let(:setting_content) do
            <<~EOH
          version: 1.0
          setting: |-
            prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
            layer :up do
              left_analog_stick_cap cap: 1000, if_pressed: [:a]
            end
            EOH
          end
          it do
            ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
            expect(ProconBypassMan.buttons_setting_configuration.layers[:up].left_analog_stick_caps).to eq([
              {:cap=>1000, if_pressed: [:a], }
            ])
          end
        end
        context 'provide a button' do
          let(:setting_content) do
            <<~EOH
          version: 1.0
          setting: |-
            prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
            layer :up do
              left_analog_stick_cap cap: 1000, if_pressed: :a
            end
            EOH
          end
          it do
            ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
            expect(ProconBypassMan.buttons_setting_configuration.layers[:up].left_analog_stick_caps).to eq([{:cap=>1000, :if_pressed=>[:a]}])
          end
        end
        context 'provide a nil' do
          let(:setting_content) do
            <<~EOH
          version: 1.0
          setting: |-
            prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
            layer :up do
              left_analog_stick_cap cap: 1000, if_pressed: nil
            end
            EOH
          end
          it do
            ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
            expect(ProconBypassMan.buttons_setting_configuration.layers[:up].left_analog_stick_caps).to eq([{:cap=>1000}])
          end
        end
        context 'do not provide' do
          let(:setting_content) do
            <<~EOH
          version: 1.0
          setting: |-
            prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
            layer :up do
              left_analog_stick_cap cap: 1000
            end
            EOH
          end
          it do
            ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
            expect(ProconBypassMan.buttons_setting_configuration.layers[:up].left_analog_stick_caps).to eq([
              cap: 1000
            ])
          end
        end
      end
      context 'with flip_interval' do
        let(:setting_content) do
          <<~EOH
          version: 1.0
          setting: |-
            prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
            layer :up do
              flip :zr, if_pressed: :zr, flip_interval: "2F"
            end
          EOH
        end
        it do
          expect {
            ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
          }.not_to raise_error
        end
        it do
          FileUtils.rm_rf("#{ProconBypassMan.root}/.setting_yaml_digest")
          ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
          expect(
            File.read("#{ProconBypassMan.root}/.setting_yaml_digest")
          ).not_to be_nil
        end
      end
      context '複数レイヤーで存在しないボタンを書いているとき' do
        let(:setting_content) do
          <<~EOH
          version: 1.0
          setting: |-
            prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
            layer :up do
              flip :n, if_pressed: :zr
              flip :p, if_pressed: :zr
            end
            layer :down do
              flip :n, if_pressed: :zr
            end
          EOH
        end
        it do
          begin
            ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
          rescue ProconBypassMan::CouldNotLoadConfigError => e
            expect(e.message).to eq("layer upで存在しないボタンn, pがあります\nlayer downで存在しないボタンnがあります")
          end
        end
      end
      context '存在しないボタンを書いているとき1-1(対象のボタン)' do
        let(:setting_content) do
          <<~EOH
          version: 1.0
          setting: |-
            prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
            layer :up do
              flip :n, if_pressed: :zr
            end
          EOH
        end
        it do
          begin
            ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
          rescue ProconBypassMan::CouldNotLoadConfigError => e
            expect(e.message).to eq("layer upで存在しないボタンnがあります")
          end
        end
      end
      context '存在しないボタンを書いているとき1-2(オプション)' do
        let(:setting_content) do
          <<~EOH
          version: 1.0
          setting: |-
            prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
            layer :up do
              flip :zr, if_pressed: :n
            end
          EOH
        end
        it do
          expect {
            ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
          }.to raise_error(
            ProconBypassMan::CouldNotLoadConfigError
          )
        end
      end
      context '存在しないボタンを書いているとき1-3(オプション)' do
        let(:setting_content) do
          <<~EOH
          version: 1.0
          setting: |-
            prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
            layer :up do
              flip :zr, if_pressed: [:n]
            end
          EOH
        end
        it do
          expect {
            ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
          }.to raise_error(
            ProconBypassMan::CouldNotLoadConfigError
          )
        end
      end
      # Layerでフィルタするようにしたのでエラーにならなくなった
      xcontext '存在しないボタンを書いているとき2-1(remap)' do
        let(:setting_content) do
          <<~EOH
          version: 1.0
          setting: |-
            prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
            layer :up do
              remap :n, to: %i(zr)
            end
          EOH
        end
        it do
          expect {
            ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
          }.to raise_error(
            ProconBypassMan::CouldNotLoadConfigError
          )
        end
      end
      context '存在しないボタンを書いているとき2-2(remap)' do
        let(:setting_content) do
          <<~EOH
          version: 1.0
          setting: |-
            prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
            layer :up do
              remap :zr, to: %i(n)
            end
          EOH
        end
        it do
          expect {
            ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
          }.to raise_error(
            ProconBypassMan::CouldNotLoadConfigError
          )
        end
      end
      context '設定内容がyamlシンタックスエラーのとき(インデントが1つ深すぎる)' do
        let(:setting_content) do
          <<~EOH
          version: 1.0
          setting: |-
              flip :zr, if_pressed: :zr
            end
          EOH
        end
        it do
          expect {
            ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
          }.to raise_error(
            ProconBypassMan::CouldNotLoadConfigError
          )
        end
      end
      context '設定内容がシンタックスエラーのとき' do
        let(:setting_content) do
          <<~EOH
          version: 1.0
          setting: |-
            layer :up do
              flip :zr, if_pressed: :zr
          EOH
        end
        it do
          expect {
            ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
          }.to raise_error(
            ProconBypassMan::CouldNotLoadConfigError
          )
        end
      end
      context '設定内容に未定義定数があるとき' do
        let(:setting_content) do
          <<~EOH
          version: 1.0
          setting: |-
            UnkownConst
            layer :up do
              flip :zr, if_pressed: :zr
          EOH
        end
        it do
          expect {
            ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
          }.to raise_error(
            ProconBypassMan::CouldNotLoadConfigError
          )
        end
      end
      context 'prefix_keys_for_changing_layerが空欄のとき' do
        let(:setting_content) do
          <<~EOH
          version: 1.0
          setting: |-
            prefix_keys_for_changing_layer []
            layer :up do
              flip :zr, if_pressed: :zr
            end
          EOH
        end
        it do
          expect {
            ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
          }.not_to raise_error
        end
      end

      context '2回instance_evalで読み込むとき' do
        it do
          c = <<~EOH
            fast_return = ProconBypassMan::Plugin::Splatoon2::Macro::FastReturn
            install_macro_plugin fast_return

            prefix_keys_for_changing_layer [:a]
            layer :up do
              flip :b, if_pressed: :b
            end
          EOH

          instance = ProconBypassMan::ButtonsSettingConfiguration.new
          ProconBypassMan.buttons_setting_configuration = instance
          instance.instance_eval(c)
          expect {
            instance = ProconBypassMan::ButtonsSettingConfiguration.new
            ProconBypassMan.buttons_setting_configuration = instance
            instance.instance_eval(c)
          }.not_to raise_error
        end
      end

      context '未定義の定数をinstance_evalで読み込むとき' do
        it do
          c = <<~EOH
            fast_fujinken = ProconBypassMan::Plugin::SmashBrothers::Macro::FastFujinken
            install_macro_plugin fast_fujinken

            prefix_keys_for_changing_layer [:a]
            layer :up do
              flip :b, if_pressed: :b
              macro fast_fujinken, if_pressed: [:a, :y]
            end
          EOH

          ProconBypassMan::ButtonsSettingConfiguration.new.instance_eval(c)
        end
      end

      context '2回loadするとき' do
        class ::AMacroPlugin
          def self.name; :the_macro; end
          def self.steps; [:a, :b]; end
        end
        class AModePlugin
          def self.name; :foo; end
          def self.binaries; ['a']; end
        end
        let(:first_setting_content) do
          <<~EOH
          version: 1.0
          setting: |-
            install_macro_plugin(AMacroPlugin)
            install_mode_plugin(AModePlugin)
            prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
            layer :up do
              flip :zr, if_pressed: :zr
            end
          EOH
        end
        let(:second_setting_content) do
          <<~EOH
          version: 1.0
          setting: |-
            install_macro_plugin(AMacroPlugin)
            install_mode_plugin(AModePlugin)
            prefix_keys_for_changing_layer [:a]
            layer :up do
              flip :b, if_pressed: :b
            end
          EOH
        end
        it '2回目の設定が設定されていること' do
          first_setting = Setting.new(first_setting_content).to_file
          second_setting = Setting.new(second_setting_content).to_file
          ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: first_setting.path)
          expect(ProconBypassMan.buttons_setting_configuration.prefix_keys).to eq([:zr, :r, :zl, :l])
          expect(ProconBypassMan.buttons_setting_configuration.layers[:up].flip_buttons).to eq(zr: { if_pressed: [:zr] })
          ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: second_setting.path)
          expect(ProconBypassMan.buttons_setting_configuration.prefix_keys).to eq([:a])
          expect(ProconBypassMan.buttons_setting_configuration.layers[:up].flip_buttons).to eq(b: { if_pressed: [:b] })
        end
      end
    end
  end

  describe '.buttons_setting_configure' do
    context 'with setting_path' do
      let(:setting_content) do
        <<~EOH
          version: 1.0
          setting: |-
            prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
            layer :up do
              flip :zr, if_pressed: :zr
            end
        EOH
      end
      it do
        ProconBypassMan.buttons_setting_configure(setting_path: setting.path)
        expect(ProconBypassMan.buttons_setting_configuration.prefix_keys).to eq([:zr, :r, :zl, :l])
        expect(ProconBypassMan.buttons_setting_configuration.layers[:up].flip_buttons).to eq(zr: { if_pressed: [:zr] })
        expect(ProconBypassMan.buttons_setting_configuration.layers[:down].flips).to eq({})
        expect(ProconBypassMan.buttons_setting_configuration.setting_path).to eq(setting.path)
      end
    end

    context 'with disable' do
      it do
        ProconBypassMan.buttons_setting_configure do
          install_macro_plugin(AMacroPlugin)
          layer :up do
            disable [:a, :l]
            disable [:b]
          end
        end
        expect(ProconBypassMan.buttons_setting_configuration.layers[:up].disables.sort).to eq([:a, :b, :l].sort)
      end
    end

    context 'with install macro plugin' do
      it do
        class AMacroPlugin
          def self.name; :the_macro; end
          def self.steps; [:a, :b]; end
        end
        ProconBypassMan.buttons_setting_configure do
          install_macro_plugin(AMacroPlugin)
          layer :up do
            macro AMacroPlugin, if_pressed: [:a, :y]
          end
        end
        expect(ProconBypassMan.buttons_setting_configuration.macro_registry.plugins.keys).to eq([:AMacroPlugin])
        expect(ProconBypassMan.buttons_setting_configuration.macro_registry.plugins[:AMacroPlugin].call).to eq([:a, :b])
        expect(ProconBypassMan.buttons_setting_configuration.layers[:up].macros).to eq(
          {:AMacroPlugin=>{:if_pressed=>[:a, :y]}}
        )
      end
      it do
        class AMacroPlugin
          def self.name; :the_macro; end
          def self.steps; [:a, :b]; end
        end
        ProconBypassMan.buttons_setting_configure do
          install_macro_plugin(AMacroPlugin)
          layer :up do
            macro AMacroPlugin, if_pressed: [:a, :y]
          end
        end
        expect(ProconBypassMan.buttons_setting_configuration.macro_registry.plugins.keys).to eq([:AMacroPlugin])
        expect(ProconBypassMan.buttons_setting_configuration.macro_registry.plugins[:AMacroPlugin].call).to eq([:a, :b])
        expect(ProconBypassMan.buttons_setting_configuration.layers[:up].macros).to eq(
          {:AMacroPlugin=>{:if_pressed=>[:a, :y]}}
        )
      end
      it do
        class AMacroPlugin
          def self.steps; [:a, :b]; end
        end
        ProconBypassMan.buttons_setting_configure do
          install_macro_plugin(AMacroPlugin)
          layer :up do
            macro AMacroPlugin, if_pressed: [:a, :y], if_tilted_left_stick: true
          end
        end
        expect(ProconBypassMan.buttons_setting_configuration.macro_registry.plugins.keys).to eq([:AMacroPlugin])
        expect(ProconBypassMan.buttons_setting_configuration.macro_registry.plugins[:AMacroPlugin].call).to eq([:a, :b])
        expect(ProconBypassMan.buttons_setting_configuration.layers[:up].macros).to eq(
          {:AMacroPlugin=>{:if_pressed=>[:a, :y], if_tilted_left_stick: true }}
        )
      end
    end
    context 'open macro' do
      context 'macro v1' do
        it do
          ProconBypassMan.buttons_setting_configure do
            layer :up do
              open_macro "SaiHuu", steps: [:x, :y], if_pressed: [:x]
              open_macro "SpecialCommand", steps: [:up, :down, :g], if_pressed: [:y]
            end
          end
          expect(ProconBypassMan.buttons_setting_configuration.macro_registry.plugins[:SaiHuu].call).to eq([:x, :y])
          expect(ProconBypassMan.buttons_setting_configuration.macro_registry.plugins[:SpecialCommand].call).to eq([:up, :down])
          expect(ProconBypassMan.buttons_setting_configuration.layers[:up].macros).to eq(
            {"SaiHuu"=>{:if_pressed=>[:x]}, "SpecialCommand"=>{:if_pressed=>[:y]}}
          )
        end
      end
      context 'macro v2' do
        it do
          ProconBypassMan.buttons_setting_configure do
            layer :up do
              open_macro :sokuwari, steps: [:toggle_r, :toggle_thumbr_for_2sec, :toggle_zr_for_1sec, :toggle_r], if_pressed: [:zr, :down]
            end
          end
          expect(ProconBypassMan.buttons_setting_configuration.macro_registry.plugins[:sokuwari].call).to eq([
              :r,
              :none,
              {:continue_for=>2, :steps=>[:thumbr, :none]},
              {:continue_for=>1, :steps=>[:zr, :none]},
              :r,
              :none,
            ])
          expect(ProconBypassMan.buttons_setting_configuration.layers[:up].macros).to eq(
            { :sokuwari => {:if_pressed=>[:zr, :down]} }
          )
        end
        context 'with if_tilted_left_stick' do
          it do
            ProconBypassMan.buttons_setting_configure do
              layer :up do
                open_macro :dacan, steps: [:pressing_r_for_0_3sec, :pressing_r_and_toggle_zl], if_tilted_left_stick: true, if_pressed: [:zr]
              end
            end
            expect(ProconBypassMan.buttons_setting_configuration.macro_registry.plugins[:dacan].call).to eq(
              [{:continue_for=>0.3, :steps=>[:r, :r]}, [:r, :zl], [:r, :none]]
            )
            expect(ProconBypassMan.buttons_setting_configuration.layers[:up].macros).to eq(
              { dacan: { if_pressed: [:zr], if_tilted_left_stick: true } }
            )
          end
          it do
            ProconBypassMan.buttons_setting_configure do
              layer :up do
                open_macro :dacan, steps: [:pressing_r_and_toggle_zr], if_tilted_left_stick: true, if_pressed: [:zr]
              end
            end
            expect(ProconBypassMan.buttons_setting_configuration.macro_registry.plugins[:dacan].call).to eq([[:r, :zr], [:r, :none]])
            expect(ProconBypassMan.buttons_setting_configuration.layers[:up].macros).to eq(
              { dacan: { if_pressed: [:zr], if_tilted_left_stick: true } }
            )
          end
          it do
            ProconBypassMan.buttons_setting_configure do
              layer :up do
                open_macro :dacan, steps: [:pressing_r_and_toggle_zr], if_tilted_left_stick: { threshold: 600 }, if_pressed: [:zr]
              end
            end
            expect(ProconBypassMan.buttons_setting_configuration.macro_registry.plugins[:dacan].call).to eq([[:r, :zr], [:r, :none]])
            expect(ProconBypassMan.buttons_setting_configuration.layers[:up].macros).to eq(
              { dacan: { if_pressed: [:zr], if_tilted_left_stick: { threshold: 600 } } }
            )
          end
          it do
            ProconBypassMan.buttons_setting_configure do
              layer :up do
                open_macro :dacan, steps: [:pressing_r_and_toggle_zr], if_tilted_left_stick: true, if_pressed: [:zr]
              end
            end
            expect(ProconBypassMan.buttons_setting_configuration.macro_registry.plugins[:dacan].call).to eq([[:r, :zr], [:r, :none]])
            expect(ProconBypassMan.buttons_setting_configuration.layers[:up].macros).to eq(
              { dacan: { if_pressed: [:zr], if_tilted_left_stick: true } }
            )
          end
          it do
            ProconBypassMan.buttons_setting_configure do
              layer :up do
                open_macro :shake_stick, steps: [:shake_left_stick_for_0_65sec], if_pressed: [:zr]
              end
            end
            expect(ProconBypassMan.buttons_setting_configuration.macro_registry.plugins[:shake_stick].call).to eq([{:continue_for=>0.65, :steps=>[:tilt_left_stick_completely_to_left, :tilt_left_stick_completely_to_right]}])
            expect(ProconBypassMan.buttons_setting_configuration.layers[:up].macros).to eq(
              { shake_stick: { if_pressed: [:zr] } }
            )
          end
          it do
            ProconBypassMan.buttons_setting_configure do
              layer :up do
                open_macro :shake_stick, steps: [:shake_left_stick_and_toggle_b_for_0_1sec], if_pressed: [:b, :r], force_neutral: [:b]
              end
            end
            expect(ProconBypassMan.buttons_setting_configuration.macro_registry.plugins[:shake_stick].call).to eq([{:continue_for=>0.1, :steps=>[[:tilt_left_stick_completely_to_left, :b], [:tilt_left_stick_completely_to_right, :none]]}])
            expect(ProconBypassMan.buttons_setting_configuration.layers[:up].macros).to eq(
              { shake_stick: { force_neutral: [:b], if_pressed: [:b, :r] } }
            )
          end
          it do
            ProconBypassMan.buttons_setting_configure do
              install_macro_plugin(ProconBypassMan::Plugin::Splatoon2::Macro::ChargeTansanBomb)
              layer :up do
                macro ProconBypassMan::Plugin::Splatoon2::Macro::ChargeTansanBomb, if_pressed: [:b, :r], force_neutral: [:b]
              end
            end
            expect(
              ProconBypassMan.buttons_setting_configuration.macro_registry.plugins[ProconBypassMan::Plugin::Splatoon2::Macro::ChargeTansanBomb.to_s.to_sym].call
            ).to eq([{:continue_for=>0.1, :steps=>[[:tilt_left_stick_completely_to_left, :b], [:tilt_left_stick_completely_to_right, :none]]}])
            expect(ProconBypassMan.buttons_setting_configuration.layers[:up].macros).to eq({
              :"ProconBypassMan::Plugin::Splatoon2::Macro::ChargeTansanBomb" => {:force_neutral=>[:b], :if_pressed=>[:b, :r]},
            })
          end
        end
      end
    end
    context 'with install mode plugin' do
      it do
        class AModePlugin
          def self.name; :foo; end
          def self.binaries; ['a']; end
        end
        ProconBypassMan.buttons_setting_configure do
          install_mode_plugin(AModePlugin)
          layer :up, mode: AModePlugin
        end
        expect(ProconBypassMan.buttons_setting_configuration.mode_registry.plugins.keys).to eq([:AModePlugin])
        expect(ProconBypassMan.buttons_setting_configuration.mode_registry.plugins[:AModePlugin].call).to eq(['a'])
      end
    end

    context 'with disable_macro' do
      it do
        ProconBypassMan.buttons_setting_configure do
          layer :up do
            disable_macro :all
          end
        end
        expect(ProconBypassMan.buttons_setting_configuration.layers[:up].disable_macros).to eq([
          {:name=>:all, :if_pressed=>[true]},
        ])
      end
      it do
        ProconBypassMan.buttons_setting_configure do
          layer :up do
            disable_macro :all, if_pressed: [:b, :y]
            disable_macro :all, if_pressed: :zr
            disable_macro :sokuwari, if_pressed: :x
          end
        end
        expect(ProconBypassMan.buttons_setting_configuration.layers[:up].disable_macros).to eq([
          {:name=>:all, :if_pressed=>[:b, :y]},
          {:name=>:all, :if_pressed=>[:zr]},
          {:if_pressed=>[:x], :name=>:sokuwari},
        ])
      end
    end

    context 'with if_pressed' do
      it do
        ProconBypassMan.buttons_setting_configure do
          layer :up do
            flip :l, if_pressed: [:y, :b], force_neutral: :y
          end
        end
        expect(ProconBypassMan.buttons_setting_configuration.layers[:up].flip_buttons[:l]).to eq(if_pressed: [:y, :b], force_neutral: [:y])
        expect(ProconBypassMan.buttons_setting_configuration.layers[:up].flip_buttons.keys).to eq([:l])
      end
    end

    context do
      it  'with remap' do
        ProconBypassMan.buttons_setting_configure do
          layer :up do
            remap :l, to: :zr
          end
        end
        expect(ProconBypassMan.buttons_setting_configuration.layers[:up].remaps).to eq(:l=>{ to: [:zr] })
      end
      it  'with remap' do
        ProconBypassMan.buttons_setting_configure do
          layer :up do
            remap :l, to: [:zr]
          end
        end
        expect(ProconBypassMan.buttons_setting_configuration.layers[:up].remaps).to eq(:l=>{ to: [:zr] })
      end
    end

    context 'with some mode' do
      it do
        class AModePlugin
          def self.name; 'foo'; end
          def self.binaries; ['a']; end
        end
        ProconBypassMan.buttons_setting_configure do
          install_mode_plugin AModePlugin
          layer :up do
            flip :l, if_pressed: true
            flip :r
          end
          layer :down, mode: AModePlugin do
            flip :r, if_pressed: [:zr, :zl]
          end
          layer :right, mode: AModePlugin
          layer :left
        end
        expect(ProconBypassMan.buttons_setting_configuration.layers[:up].flip_buttons[:l]).to eq(if_pressed: [:l])
        expect(ProconBypassMan.buttons_setting_configuration.layers[:up].flip_buttons[:r]).to eq(if_pressed: false)
        expect(ProconBypassMan.buttons_setting_configuration.layers[:up].flip_buttons.keys).to eq([:l, :r])
        expect(ProconBypassMan.buttons_setting_configuration.layers[:up].mode).to eq(:manual)
        expect(ProconBypassMan.buttons_setting_configuration.layers[:down].flip_buttons.keys).to eq([:r])
        expect(ProconBypassMan.buttons_setting_configuration.layers[:down].flip_buttons[:r]).to eq(if_pressed: [:zr, :zl])
        expect(ProconBypassMan.buttons_setting_configuration.layers[:down].mode).to eq(:AModePlugin)
        expect(ProconBypassMan.buttons_setting_configuration.layers[:right].flip_buttons.keys).to eq([])
        expect(ProconBypassMan.buttons_setting_configuration.layers[:right].mode).to eq(:AModePlugin)
        expect(ProconBypassMan.buttons_setting_configuration.layers[:left].flip_buttons.keys).to eq([])
        expect(ProconBypassMan.buttons_setting_configuration.layers[:left].mode).to eq(:manual)
      end
    end

    context 'has values' do
      it do
        ProconBypassMan.buttons_setting_configure do
          layer :up do
            flip :l
            flip :r
          end
          layer :down do
            flip :r
          end
          layer :right
          layer :left
        end
        expect(ProconBypassMan.buttons_setting_configuration.layers[:up].flip_buttons.keys).to eq([:l, :r])
        expect(ProconBypassMan.buttons_setting_configuration.layers[:down].flip_buttons.keys).to eq([:r])
        expect(ProconBypassMan.buttons_setting_configuration.layers[:right].flip_buttons.keys).to eq([])
        expect(ProconBypassMan.buttons_setting_configuration.layers[:left].flip_buttons.keys).to eq([])
      end
    end

    context '全部空' do
      it do
        ProconBypassMan.buttons_setting_configure do
          layer :up do
          end
          layer :down do
          end
          layer :right do
          end
          layer :left do
          end
        end
        expect(ProconBypassMan.buttons_setting_configuration.layers[:up].flip_buttons.keys).to eq([])
        expect(ProconBypassMan.buttons_setting_configuration.layers[:down].flip_buttons.keys).to eq([])
        expect(ProconBypassMan.buttons_setting_configuration.layers[:right].flip_buttons.keys).to eq([])
        expect(ProconBypassMan.buttons_setting_configuration.layers[:left].flip_buttons.keys).to eq([])
      end
    end

    describe 'prefix_keys_for_changing_layer' do
      it do
        ProconBypassMan.buttons_setting_configure do
          prefix_keys_for_changing_layer [:zr]
        end
        expect(ProconBypassMan.buttons_setting_configuration.prefix_keys).to eq([:zr])
      end
    end

    context 'flip_interval' do
      it do
        ProconBypassMan.buttons_setting_configure do
          layer :up do
            flip :zr, flip_interval: "8F"
          end
        end
        expect(ProconBypassMan.buttons_setting_configuration.layers[:up].flip_buttons[:zr][:flip_interval]).to eq(0.13)
      end
    end
  end

  describe 'validations' do
    describe '設定構文として不正だけど警告だけを出す' do
      context 'installしていないpluginを使うとき' do
        context 'macro' do
          it 'ロードしない' do
            ProconBypassMan.buttons_setting_configure do
              layer :up do
                macro ProconBypassMan::Plugin::Splatoon2::Macro::FastReturn, if_pressed: :a
              end
            end
            expect(ProconBypassMan.buttons_setting_configuration.layers[:up].macros).to eq({})
          end
        end

        context 'mode' do
          it 'ロードしない' do
            class AModePlugin
              def self.binaries; ['a']; end
            end
            ProconBypassMan.buttons_setting_configure do
              layer :up, mode: AModePlugin
            end

            expect(ProconBypassMan.buttons_setting_configuration.mode_registry.plugins.keys).to eq([])
          end
        end
      end
    end

    context 'NameErrorが起きるとき' do
      it 'ProconBypassMan::CouldNotLoadConfigErrorエラーを投げること' do
        setting_content = <<~EOH
          version: 1.0
          setting: |-
            ProconBypassMan::Splatoon2::Macro::Foo
            prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
            set_neutral_position 1000, 1000
        EOH
        ProconBypassMan.buttons_setting_configuration.setting_path = nil
        setting = Setting.new(setting_content).to_file

        expect {
          ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
        }.to raise_error(ProconBypassMan::CouldNotLoadConfigError)
      end
    end

    context 'シンタックスエラーが起きるとき' do
      context '初回で失敗する' do
        it 'setting_pathはnilのままであること' do
          invalid_setting_content = <<~EOH
          version: 1.0
          setting: |-
            prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
            set_neutral_position 1000,, 1000
          EOH
          ProconBypassMan.buttons_setting_configuration.setting_path = nil
          invalid_setting = Setting.new(invalid_setting_content).to_file
          begin
            ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: invalid_setting.path)
          rescue ProconBypassMan::CouldNotLoadConfigError
            expect(ProconBypassMan.buttons_setting_configuration.setting_path).to be_nil
          end
        end
      end

      context '初回は成功して、次に設定ファイルをロードするとき' do
        let(:setting_content) {
          <<~EOH
            version: 1.0
            setting: |-
              prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
              set_neutral_position 1000, 1000
          EOH
        }
        let(:error_setting_content) {
          <<~EOH
            version: 1.0
            setting: |-
              prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
              set_neutral_position 1000,, 1000
          EOH
        }

        before do
          valid_setting = Setting.new(setting_content).to_file
          ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: valid_setting.path)
          expect(ProconBypassMan.buttons_setting_configuration.prefix_keys).to eq([:zr, :r, :zl, :l])
          expect(ProconBypassMan.buttons_setting_configuration.setting_path).to eq(valid_setting.path)
        end

        context 'fallback_pathがある' do
          before { File.write(ProconBypassMan.fallback_setting_path, setting_content) }
          it 'invalid_setting_contentの内容はファイルに保存されないこと' do
            invalid_setting = Setting.new(error_setting_content).to_file
            expect { ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: invalid_setting.path) }.to raise_error ProconBypassMan::CouldNotLoadConfigError
            expect(File.read(invalid_setting.path)).to eq(setting_content)
            expect(File.exist?(ProconBypassMan.fallback_setting_path)).to eq(false)
          end

          it '変更はオブジェクトには反映されないこと' do
            previous_configuration = ProconBypassMan.buttons_setting_configuration.dup
            invalid_setting = Setting.new(error_setting_content).to_file
            begin
              ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: invalid_setting.path)
            rescue ProconBypassMan::CouldNotLoadConfigError
              expect(ProconBypassMan.buttons_setting_configuration.prefix_keys).to eq([:zr, :r, :zl, :l])
              expect(ProconBypassMan.buttons_setting_configuration.setting_path).to eq(previous_configuration.setting_path)
            end
          end
        end

        context 'fallback_pathがない' do
          it 'invalid_setting_contentの内容はファイルに保存されること' do
            invalid_setting = Setting.new(error_setting_content).to_file
            expect { ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: invalid_setting.path) }.to raise_error ProconBypassMan::CouldNotLoadConfigError
            expect(File.read(invalid_setting.path)).to eq(error_setting_content)
          end

          it '変更はオブジェクトには反映されないこと' do
            previous_configuration = ProconBypassMan.buttons_setting_configuration.dup
            invalid_setting = Setting.new(error_setting_content).to_file
            begin
              ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: invalid_setting.path)
            rescue ProconBypassMan::CouldNotLoadConfigError
              expect(ProconBypassMan.buttons_setting_configuration.prefix_keys).to eq([:zr, :r, :zl, :l])
              expect(ProconBypassMan.buttons_setting_configuration.setting_path).to eq(previous_configuration.setting_path)
            end
          end
        end
      end
    end

    context '未定義のmacro定数をinstance_evalで読み込むとき' do
      it do
        c = <<~EOH
            fast_fujinken = ProconBypassMan::Plugin::SmashBrothers::Macro::FastFujinken
            fast_return = ProconBypassMan::Plugin::Splatoon2::Macro::FastReturn

            install_macro_plugin fast_fujinken
            install_macro_plugin fast_return

            prefix_keys_for_changing_layer [:a]
            layer :up do
              flip :b, if_pressed: :b
              macro fast_fujinken, if_pressed: [:a, :y]
            end
        EOH

        instance = ProconBypassMan::ButtonsSettingConfiguration.new
        ProconBypassMan.buttons_setting_configuration = instance
        instance.instance_eval(c)
        validator = ProconBypassMan::ButtonsSettingConfiguration::Validator.new(
          ProconBypassMan.buttons_setting_configuration
        )
        expect(validator.valid?).to eq(false)
        expect(validator.errors).to eq(:macro=>["マクロ ProconBypassMan::Plugin::SmashBrothers::Macro::FastFujinkenを読み込めませんでした。"])
      end
    end

    context '未定義のmode定数をinstance_evalで読み込むとき' do
      it do
        c = <<~EOH
            eternal_jump = ProconBypassMan::Plugin::SmashBrothers::Mode::EternalJump
            guruguru = ProconBypassMan::Plugin::Splatoon2::Mode::Guruguru

            install_mode_plugin eternal_jump
            install_mode_plugin guruguru

            prefix_keys_for_changing_layer [:a]
            layer :up, mode: eternal_jump do
            end
        EOH

        instance = ProconBypassMan::ButtonsSettingConfiguration.new
        ProconBypassMan.buttons_setting_configuration = instance
        ProconBypassMan.buttons_setting_configuration.instance_eval(c)
        validator = ProconBypassMan::ButtonsSettingConfiguration::Validator.new(
          ProconBypassMan.buttons_setting_configuration
        )
        expect(validator.valid?).to eq(false)
        expect(validator.errors).to eq(:mode=>["モード ProconBypassMan::Plugin::SmashBrothers::Mode::EternalJumpを読み込めませんでした。"])
      end
    end

    context '同じレイヤーで同じボタンへの設定をしているとき' do
      it do
        expect {
        ProconBypassMan.buttons_setting_configure do
          prefix_keys_for_changing_layer [:zr]
          layer :up do
            flip :zr, if_pressed: [:y]
            flip :zr, if_pressed: [:x]
          end
        end
        }.not_to raise_error
        expect(ProconBypassMan::ButtonsSettingConfiguration::Validator.new(
          ProconBypassMan.buttons_setting_configuration
        ).valid?).to eq(true)
        expect(ProconBypassMan.buttons_setting_configuration.layers[:up].flips).to eq(:zr=>{:if_pressed=>[:x]})
      end
    end

    context '同じレイヤーで1つのボタンへのflipとremapを設定をしているとき' do
      it do
        ProconBypassMan.buttons_setting_configure do
          prefix_keys_for_changing_layer [:zr]
          layer :up do
            flip :zr, if_pressed: [:y]
            remap :zr, to: [:y]
            flip :y, if_pressed: [:y]
            flip :l, if_pressed: [:zr]
            flip :r, if_pressed: [:y]
          end
        end
        validator = ProconBypassMan::ButtonsSettingConfiguration::Validator.new(
          ProconBypassMan.buttons_setting_configuration
        )
        expect(validator.valid?).to eq(false)
        expect(validator.errors).to eq({:layers=>["レイヤーupで、連打とリマップの定義が重複しているボタンzrがあります"]})
      end
    end

    context 'modeを設定しているのにブロックを渡しているとき' do
      it do
        class AModePlugin
          def self.name; :foo; end
          def self.binaries; ['a']; end
        end
        ProconBypassMan.buttons_setting_configure do
          prefix_keys_for_changing_layer [:zr]
          install_mode_plugin AModePlugin
          layer :up, mode: AModePlugin do
            flip :zr
          end
        end
        validator = ProconBypassMan::ButtonsSettingConfiguration::Validator.new(
          ProconBypassMan.buttons_setting_configuration
        )
        expect(validator.valid?).to eq(false)
        expect(validator.errors).to eq(:layers=>["upでmodeを設定しているのでボタンの設定はできません。"])
      end
    end
  end
end
