require "spec_helper"

describe ProconBypassMan::Configuration do
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
          ProconBypassMan::Configuration::Loader.load(setting_path: setting.path)
          expect(ProconBypassMan::Configuration.instance.neutral_position.x).to eq(1000)
          expect(ProconBypassMan::Configuration.instance.neutral_position.y).to eq(1000)
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
            ProconBypassMan::Configuration::Loader.load(setting_path: setting.path)
            expect(ProconBypassMan::Configuration.instance.layers[:up].left_analog_stick_caps[[:a]]).to eq(
              {:cap=>1000, :force_neutral=> [:a] }
            )
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
            ProconBypassMan::Configuration::Loader.load(setting_path: setting.path)
            expect(ProconBypassMan::Configuration.instance.layers[:up].left_analog_stick_caps.keys).to eq([[:a]])
            expect(ProconBypassMan::Configuration.instance.layers[:up].left_analog_stick_caps[[:a]]).to eq(
              {:cap=>1000}
            )
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
            ProconBypassMan::Configuration::Loader.load(setting_path: setting.path)
            expect(ProconBypassMan::Configuration.instance.layers[:up].left_analog_stick_caps.keys).to eq([[:a]])
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
            ProconBypassMan::Configuration::Loader.load(setting_path: setting.path)
            expect(ProconBypassMan::Configuration.instance.layers[:up].left_analog_stick_caps.keys).to eq([nil])
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
            ProconBypassMan::Configuration::Loader.load(setting_path: setting.path)
            expect(ProconBypassMan::Configuration.instance.layers[:up].left_analog_stick_caps.keys).to eq([nil])
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
            ProconBypassMan::Configuration::Loader.load(setting_path: setting.path)
          }.not_to raise_error
        end
        it do
          FileUtils.rm_rf("#{ProconBypassMan.root}/.setting_yaml_digest")
          ProconBypassMan::Configuration::Loader.load(setting_path: setting.path)
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
            ProconBypassMan::Configuration::Loader.load(setting_path: setting.path)
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
            ProconBypassMan::Configuration::Loader.load(setting_path: setting.path)
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
            ProconBypassMan::Configuration::Loader.load(setting_path: setting.path)
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
            ProconBypassMan::Configuration::Loader.load(setting_path: setting.path)
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
            ProconBypassMan::Configuration::Loader.load(setting_path: setting.path)
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
            ProconBypassMan::Configuration::Loader.load(setting_path: setting.path)
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
            ProconBypassMan::Configuration::Loader.load(setting_path: setting.path)
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
            ProconBypassMan::Configuration::Loader.load(setting_path: setting.path)
          }.to raise_error(
            ProconBypassMan::CouldNotLoadConfigError
          )
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
          ProconBypassMan::Configuration::Loader.load(setting_path: first_setting.path)
          expect(ProconBypassMan::Configuration.instance.prefix_keys).to eq([:zr, :r, :zl, :l])
          expect(ProconBypassMan::Configuration.instance.layers[:up].flip_buttons).to eq(zr: { if_pressed: [:zr] })
          ProconBypassMan::Configuration::Loader.load(setting_path: second_setting.path)
          expect(ProconBypassMan::Configuration.instance.prefix_keys).to eq([:a])
          expect(ProconBypassMan::Configuration.instance.layers[:up].flip_buttons).to eq(b: { if_pressed: [:b] })
        end
      end
    end
  end

  describe '.configure' do
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
        ProconBypassMan.configure(setting_path: setting.path)
        expect(ProconBypassMan::Configuration.instance.prefix_keys).to eq([:zr, :r, :zl, :l])
        expect(ProconBypassMan::Configuration.instance.layers[:up].flip_buttons).to eq(zr: { if_pressed: [:zr] })
        expect(ProconBypassMan::Configuration.instance.layers[:down].flips).to eq({})
        expect(ProconBypassMan::Configuration.instance.setting_path).to eq(setting.path)
      end
    end

    context 'with disable' do
      it do
        ProconBypassMan.configure do
          install_macro_plugin(AMacroPlugin)
          layer :up do
            disable [:a, :l]
            disable [:b]
          end
        end
        expect(ProconBypassMan::Configuration.instance.layers[:up].disables.sort).to eq([:a, :b, :l].sort)
      end
    end

    context 'with install macro plugin' do
      it do
        class AMacroPlugin
          def self.name; :the_macro; end
          def self.steps; [:a, :b]; end
        end
        ProconBypassMan.configure do
          install_macro_plugin(AMacroPlugin)
          layer :up do
            macro :the_macro, if_pressed: [:a, :y]
          end
        end
        expect(ProconBypassMan::Procon::MacroRegistry.plugins).to eq(the_macro: [:a, :b])
        expect(ProconBypassMan::Configuration.instance.layers[:up].macros).to eq(
          {:the_macro=>{:if_pressed=>[:a, :y]}}
        )
      end
      it do
        class AMacroPlugin
          def self.name; :the_macro; end
          def self.steps; [:a, :b]; end
        end
        ProconBypassMan.configure do
          install_macro_plugin(AMacroPlugin)
          layer :up do
            macro AMacroPlugin, if_pressed: [:a, :y]
          end
        end
        expect(ProconBypassMan::Procon::MacroRegistry.plugins).to eq(the_macro: [:a, :b])
        expect(ProconBypassMan::Configuration.instance.layers[:up].macros).to eq(
          {:the_macro=>{:if_pressed=>[:a, :y]}}
        )
      end
    end
    context 'with install mode plugin' do
      it do
        class AModePlugin
          def self.name; :foo; end
          def self.binaries; ['a']; end
        end
        ProconBypassMan.configure do
          install_mode_plugin(AModePlugin)
          layer :up, mode: AModePlugin.name
        end
        expect(ProconBypassMan::Procon::ModeRegistry.plugins).to eq(foo: ['a'])
      end
    end

    context 'with if_pressed' do
      it do
        ProconBypassMan.configure do
          layer :up do
            flip :l, if_pressed: [:y, :b], force_neutral: :y
          end
        end
        expect(ProconBypassMan::Configuration.instance.layers[:up].flip_buttons[:l]).to eq(if_pressed: [:y, :b], force_neutral: [:y])
        expect(ProconBypassMan::Configuration.instance.layers[:up].flip_buttons.keys).to eq([:l])
      end
    end

    context do
      it  'with remap' do
        ProconBypassMan.configure do
          layer :up do
            remap :l, to: :zr
          end
        end
        expect(ProconBypassMan::Configuration.instance.layers[:up].remaps).to eq(:l=>{ to: [:zr] })
      end
      it  'with remap' do
        expect {
          ProconBypassMan.configure do
            layer :up do
              remap :l, to: []
            end
          end
        }.to raise_error RuntimeError, "ボタンを渡してください"
      end
      it  'with remap' do
        ProconBypassMan.configure do
          layer :up do
            remap :l, to: [:zr]
          end
        end
        expect(ProconBypassMan::Configuration.instance.layers[:up].remaps).to eq(:l=>{ to: [:zr] })
      end
    end

    context 'with some mode' do
      it do
        class AModePlugin
          def self.name; 'foo'; end
          def self.binaries; ['a']; end
        end
        ProconBypassMan.configure do
          install_mode_plugin AModePlugin
          layer :up do
            flip :l, if_pressed: true
            flip :r
          end
          layer :down, mode: :manual do
            flip :r, if_pressed: [:zr, :zl]
          end
          layer :right, mode: AModePlugin.name
          layer :left
        end
        expect(ProconBypassMan::Configuration.instance.layers[:up].flip_buttons[:l]).to eq(if_pressed: [:l])
        expect(ProconBypassMan::Configuration.instance.layers[:up].flip_buttons[:r]).to eq(if_pressed: false)
        expect(ProconBypassMan::Configuration.instance.layers[:up].flip_buttons.keys).to eq([:l, :r])
        expect(ProconBypassMan::Configuration.instance.layers[:up].mode).to eq(:manual)
        expect(ProconBypassMan::Configuration.instance.layers[:down].flip_buttons.keys).to eq([:r])
        expect(ProconBypassMan::Configuration.instance.layers[:down].flip_buttons[:r]).to eq(if_pressed: [:zr, :zl])
        expect(ProconBypassMan::Configuration.instance.layers[:down].mode).to eq(:manual)
        expect(ProconBypassMan::Configuration.instance.layers[:right].flip_buttons.keys).to eq([])
        expect(ProconBypassMan::Configuration.instance.layers[:right].mode).to eq(:foo)
        expect(ProconBypassMan::Configuration.instance.layers[:left].flip_buttons.keys).to eq([])
        expect(ProconBypassMan::Configuration.instance.layers[:left].mode).to eq(:manual)
      end
    end

    context 'has values' do
      it do
        ProconBypassMan.configure do
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
        expect(ProconBypassMan::Configuration.instance.layers[:up].flip_buttons.keys).to eq([:l, :r])
        expect(ProconBypassMan::Configuration.instance.layers[:down].flip_buttons.keys).to eq([:r])
        expect(ProconBypassMan::Configuration.instance.layers[:right].flip_buttons.keys).to eq([])
        expect(ProconBypassMan::Configuration.instance.layers[:left].flip_buttons.keys).to eq([])
      end
    end

    context '全部空' do
      it do
        ProconBypassMan.configure do
          layer :up do
          end
          layer :down do
          end
          layer :right do
          end
          layer :left do
          end
        end
        expect(ProconBypassMan::Configuration.instance.layers[:up].flip_buttons.keys).to eq([])
        expect(ProconBypassMan::Configuration.instance.layers[:down].flip_buttons.keys).to eq([])
        expect(ProconBypassMan::Configuration.instance.layers[:right].flip_buttons.keys).to eq([])
        expect(ProconBypassMan::Configuration.instance.layers[:left].flip_buttons.keys).to eq([])
      end
    end

    describe 'prefix_keys_for_changing_layer' do
      it do
        ProconBypassMan.configure do
          prefix_keys_for_changing_layer [:zr]
        end
        expect(ProconBypassMan::Configuration.instance.prefix_keys).to eq([:zr])
      end
    end

    context 'flip_interval' do
      it do
        ProconBypassMan.configure do
          layer :up do
            flip :zr, flip_interval: "8F"
          end
        end
        expect(ProconBypassMan::Configuration.instance.layers[:up].flip_buttons[:zr][:flip_interval]).to eq(0.13)
      end
    end
  end

  describe 'validations' do
    context '同じレイヤーで同じボタンへの設定をしているとき' do
      it do
        # TODO validationとして捕捉したい
        expect {
        ProconBypassMan.configure do
          prefix_keys_for_changing_layer [:zr]
          layer :up do
            flip :zr, if_pressed: [:y]
            flip :zr, if_pressed: [:x]
          end
        end
        }.to raise_error(RuntimeError, "zrへの設定をすでに割り当て済みです")
        # expect(ProconBypassMan::Configuration.instance.valid?).to eq(false)
        # expect(ProconBypassMan::Configuration.instance.errors).to eq(:layers=>["upで同じボタンへの設定はできません。"])
      end
    end
    context '同じレイヤーで1つのボタンへのflipとremapを設定をしているとき' do
      it do
        ProconBypassMan.configure do
          prefix_keys_for_changing_layer [:zr]
          layer :up do
            flip :zr, if_pressed: [:y]
            remap :zr, to: [:y]
            flip :y, if_pressed: [:y]
            flip :l, if_pressed: [:zr]
            flip :r, if_pressed: [:y]
          end
        end
        validator = ProconBypassMan::Configuration::Validator.new(
          ProconBypassMan::Configuration.instance
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
        ProconBypassMan.configure do
          prefix_keys_for_changing_layer [:zr]
          install_mode_plugin AModePlugin
          layer :up, mode: AModePlugin do
            flip :zr
          end
        end
        validator = ProconBypassMan::Configuration::Validator.new(
          ProconBypassMan::Configuration.instance
        )
        expect(validator.valid?).to eq(false)
        expect(validator.errors).to eq(:layers=>["upでmodeを設定しているのでボタンの設定はできません。"])
      end
    end
  end
end
