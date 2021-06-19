require "spec_helper"

describe ProconBypassMan::Configuration do
  before(:each) do
    ProconBypassMan.reset!
  end

  describe '.configure' do
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
    context 'with macro' do
      it do
        ProconBypassMan.configure do
          layer :up do
            macro :fast_return, if_pressed: [:y, :b, :down]
          end
        end
      end
    end

    context 'with if_pressed' do
      it do
        ProconBypassMan.configure do
          layer :up do
            flip :l, if_pressed: [:y, :b], force_neutral: :y
          end
          layer :down
          layer :right
          layer :left
        end
        expect(ProconBypassMan::Configuration.instance.layers[:up].flip_buttons[:l]).to eq(if_pressed: [:y, :b], force_neutral: :y)
        expect(ProconBypassMan::Configuration.instance.layers[:up].flip_buttons.keys).to eq([:l])
      end
    end

    context 'with some mode' do
      it do
        class AModePlugin
          def self.name; :foo; end
          def self.binaries; ['a']; end
        end
        ProconBypassMan.configure do
          install_mode_plugin AModePlugin
          layer :up do
            flip :l, if_pressed: true
            flip :r, channel: 1
          end
          layer :down, mode: :manual do
            flip :r, if_pressed: [:zr, :zl]
          end
          layer :right, mode: :foo
          layer :left
        end
        expect(ProconBypassMan::Configuration.instance.layers[:up].flip_buttons[:l]).to eq(if_pressed: [:l])
        expect(ProconBypassMan::Configuration.instance.layers[:up].flip_buttons[:r]).to eq(if_pressed: false, channel: 1)
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
  end

  describe 'prefix_keys_for_changing_layer' do
    it do
      ProconBypassMan.configure do
        prefix_keys_for_changing_layer [:zr]
      end
      expect(ProconBypassMan::Configuration.instance.prefix_keys).to eq([:zr])
    end
  end
end
