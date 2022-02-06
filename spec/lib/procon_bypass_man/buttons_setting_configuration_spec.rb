require "spec_helper"

describe ProconBypassMan::ButtonsSettingConfiguration do
  before(:each) do
    ProconBypassMan.reset!
  end
  let(:setting) { Setting.new(setting_content).to_file }

  describe 'Loader' do
    describe '.load' do
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
          expect(ProconBypassMan::ButtonsSettingConfiguration.instance.neutral_position.x).to eq(1000)
          expect(ProconBypassMan::ButtonsSettingConfiguration.instance.neutral_position.y).to eq(1000)
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
            expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:up].left_analog_stick_caps).to eq([
              {:cap=>1000, :force_neutral=> [:a], if_pressed: [:a] }
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
            expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:up].left_analog_stick_caps).to eq([
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
            expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:up].left_analog_stick_caps).to eq([{:cap=>1000, :if_pressed=>[:a]}])
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
            expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:up].left_analog_stick_caps).to eq([{:cap=>1000}])
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
            expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:up].left_analog_stick_caps).to eq([
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
            expect(e.message).to include "upで存在しないボタンnがあります"
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
      context '存在しないボタンを書いているとき2-1(remap)' do
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
      context '設定内容が不正のとき' do
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
          }.to raise_error(
            ProconBypassMan::CouldNotLoadConfigError
          )
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
          ProconBypassMan::ButtonsSettingConfiguration.instance = instance
          instance.instance_eval(c)
          expect {
            instance = ProconBypassMan::ButtonsSettingConfiguration.new
            ProconBypassMan::ButtonsSettingConfiguration.instance = instance
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
          expect(ProconBypassMan::ButtonsSettingConfiguration.instance.prefix_keys).to eq([:zr, :r, :zl, :l])
          expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:up].flip_buttons).to eq(zr: { if_pressed: [:zr] })
          ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: second_setting.path)
          expect(ProconBypassMan::ButtonsSettingConfiguration.instance.prefix_keys).to eq([:a])
          expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:up].flip_buttons).to eq(b: { if_pressed: [:b] })
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
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.prefix_keys).to eq([:zr, :r, :zl, :l])
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:up].flip_buttons).to eq(zr: { if_pressed: [:zr] })
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:down].flips).to eq({})
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.setting_path).to eq(setting.path)
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
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:up].disables.sort).to eq([:a, :b, :l].sort)
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
            macro :the_macro, if_pressed: [:a, :y]
          end
        end
        expect(ProconBypassMan::Procon::MacroRegistry.plugins.keys).to eq([:AMacroPlugin])
        expect(ProconBypassMan::Procon::MacroRegistry.plugins[:AMacroPlugin].call).to eq([:a, :b])
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:up].macros).to eq(
          {:the_macro=>{:if_pressed=>[:a, :y]}}
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
        expect(ProconBypassMan::Procon::MacroRegistry.plugins.keys).to eq([:AMacroPlugin])
        expect(ProconBypassMan::Procon::MacroRegistry.plugins[:AMacroPlugin].call).to eq([:a, :b])
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:up].macros).to eq(
          {:AMacroPlugin=>{:if_pressed=>[:a, :y]}}
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
          expect(ProconBypassMan::Procon::MacroRegistry.plugins[:SaiHuu].call).to eq([:x, :y])
          expect(ProconBypassMan::Procon::MacroRegistry.plugins[:SpecialCommand].call).to eq([:up, :down])
          expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:up].macros).to eq(
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
          expect(ProconBypassMan::Procon::MacroRegistry.plugins[:sokuwari].call).to eq([:r, :none, {:continue_for=>2, :steps=>[:thumbr, :none]}, {:continue_for=>1, :steps=>[:zr, :none]}, :r, :none])
          expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:up].macros).to eq(
            { :sokuwari => {:if_pressed=>[:zr, :down]} }
          )
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
        expect(ProconBypassMan::Procon::ModeRegistry.plugins.keys).to eq([:AModePlugin])
        expect(ProconBypassMan::Procon::ModeRegistry.plugins[:AModePlugin].call).to eq(['a'])
      end
    end

    context 'with if_pressed' do
      it do
        ProconBypassMan.buttons_setting_configure do
          layer :up do
            flip :l, if_pressed: [:y, :b], force_neutral: :y
          end
        end
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:up].flip_buttons[:l]).to eq(if_pressed: [:y, :b], force_neutral: [:y])
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:up].flip_buttons.keys).to eq([:l])
      end
    end

    context do
      it  'with remap' do
        ProconBypassMan.buttons_setting_configure do
          layer :up do
            remap :l, to: :zr
          end
        end
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:up].remaps).to eq(:l=>{ to: [:zr] })
      end
      it  'with remap' do
        expect {
          ProconBypassMan.buttons_setting_configure do
            layer :up do
              remap :l, to: []
            end
          end
        }.to raise_error RuntimeError, "ボタンを渡してください"
      end
      it  'with remap' do
        ProconBypassMan.buttons_setting_configure do
          layer :up do
            remap :l, to: [:zr]
          end
        end
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:up].remaps).to eq(:l=>{ to: [:zr] })
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
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:up].flip_buttons[:l]).to eq(if_pressed: [:l])
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:up].flip_buttons[:r]).to eq(if_pressed: false)
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:up].flip_buttons.keys).to eq([:l, :r])
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:up].mode).to eq(:manual)
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:down].flip_buttons.keys).to eq([:r])
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:down].flip_buttons[:r]).to eq(if_pressed: [:zr, :zl])
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:down].mode).to eq(:AModePlugin)
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:right].flip_buttons.keys).to eq([])
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:right].mode).to eq(:AModePlugin)
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:left].flip_buttons.keys).to eq([])
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:left].mode).to eq(:manual)
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
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:up].flip_buttons.keys).to eq([:l, :r])
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:down].flip_buttons.keys).to eq([:r])
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:right].flip_buttons.keys).to eq([])
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:left].flip_buttons.keys).to eq([])
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
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:up].flip_buttons.keys).to eq([])
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:down].flip_buttons.keys).to eq([])
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:right].flip_buttons.keys).to eq([])
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:left].flip_buttons.keys).to eq([])
      end
    end

    describe 'prefix_keys_for_changing_layer' do
      it do
        ProconBypassMan.buttons_setting_configure do
          prefix_keys_for_changing_layer [:zr]
        end
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.prefix_keys).to eq([:zr])
      end
    end

    context 'flip_interval' do
      it do
        ProconBypassMan.buttons_setting_configure do
          layer :up do
            flip :zr, flip_interval: "8F"
          end
        end
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:up].flip_buttons[:zr][:flip_interval]).to eq(0.13)
      end
    end
  end

  describe 'validations' do
    context 'シンタックスエラーが起きるとき' do
      before do
        setting_content = <<~EOH
          version: 1.0
          setting: |-
            prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
            set_neutral_position 1000, 1000
        EOH
        setting = Setting.new(setting_content).to_file
        ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.prefix_keys).to eq([:zr, :r, :zl, :l])
      end
      it '変更は反映されないこと' do
        setting_content = <<~EOH
          version: 1.0
          setting: |-
            prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
            set_neutral_position 1000,, 1000
        EOH
        setting = Setting.new(setting_content).to_file
        begin
          ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)
        rescue ProconBypassMan::CouldNotLoadConfigError
          expect(ProconBypassMan::ButtonsSettingConfiguration.instance.prefix_keys).to eq([:zr, :r, :zl, :l])
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
        ProconBypassMan::ButtonsSettingConfiguration.instance = instance
        instance.instance_eval(c)
        validator = ProconBypassMan::ButtonsSettingConfiguration::Validator.new(
          ProconBypassMan::ButtonsSettingConfiguration.instance
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
        ProconBypassMan::ButtonsSettingConfiguration.instance = instance
        ProconBypassMan::ButtonsSettingConfiguration.instance.instance_eval(c)
        validator = ProconBypassMan::ButtonsSettingConfiguration::Validator.new(
          ProconBypassMan::ButtonsSettingConfiguration.instance
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
          ProconBypassMan::ButtonsSettingConfiguration.instance
        ).valid?).to eq(true)
        expect(ProconBypassMan::ButtonsSettingConfiguration.instance.layers[:up].flips).to eq(:zr=>{:if_pressed=>[:x]})
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
          ProconBypassMan::ButtonsSettingConfiguration.instance
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
          ProconBypassMan::ButtonsSettingConfiguration.instance
        )
        expect(validator.valid?).to eq(false)
        expect(validator.errors).to eq(:layers=>["upでmodeを設定しているのでボタンの設定はできません。"])
      end
    end
  end
end
