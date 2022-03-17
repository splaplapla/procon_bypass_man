require "spec_helper"

describe ProconBypassMan::Procon::MacroRegistry do
  before do
    ProconBypassMan::Procon::MacroRegistry.reset!
  end

  describe '.cleanup_remote_macros!' do
    subject { described_class.cleanup_remote_macros! }

    Mod2 = Module.new do
      def self.steps
        [:a]
      end
    end

    before do
      ProconBypassMan::Procon::MacroRegistry.install_plugin(Mod)
      ProconBypassMan::Procon::MacroRegistry.install_plugin("like open_macro", steps: [:x], macro_type: :remote)
    end

    it do
      expect { subject }.to change {
        ProconBypassMan::Procon::MacroRegistry.plugins.raw_keys
      }.from(
        [[:Mod, :normal], [:"like open_macro", :remote]]
      ).to(
        [[:Mod, :normal]]
      )
    end
  end

  describe '.install_plugin' do
    Mod = Module.new do
      def self.steps
        [:a]
      end
    end

    context 'macro_typeを未指定のとき' do
      before do
        ProconBypassMan::Procon::MacroRegistry.install_plugin(Mod)
      end

      it do
        expect(ProconBypassMan::Procon::MacroRegistry.plugins.keys).to eq([:Mod])
        ProconBypassMan::Procon::MacroRegistry.load(:Mod)
        expect(ProconBypassMan::Procon::MacroRegistry.plugins.raw_keys).to eq([[:Mod, :normal]])
      end

      context 'macro_typeを指定する' do
        it do
          actual = ProconBypassMan::Procon::MacroRegistry.load(:Mod, macro_type: :normal)
          expect(actual.steps).to eq([:a])
          expect(actual.name).to eq(:Mod)
        end

        it do
          actual = ProconBypassMan::Procon::MacroRegistry.load(:Mod, macro_type: :remote)
          expect(actual.steps).to eq([])
          expect(actual.name).to eq(:null)
        end
      end

      context 'macro_typeを未指定' do
        it do
          actual = ProconBypassMan::Procon::MacroRegistry.load(:Mod)
          expect(actual.steps).to eq([:a])
          expect(actual.name).to eq(:Mod)
        end
      end
    end

    context 'macro_type: :remoteで指定するとき' do
      before do
        ProconBypassMan::Procon::MacroRegistry.install_plugin("like open_macro", steps: [:x], macro_type: :remote)
      end

      it do
        expect(ProconBypassMan::Procon::MacroRegistry.plugins.keys).to eq([:"like open_macro"])
        expect(ProconBypassMan::Procon::MacroRegistry.plugins.raw_keys).to eq([[:"like open_macro", :remote]])
      end

      context 'macro_typeを指定する' do
        it do
          actual = ProconBypassMan::Procon::MacroRegistry.load(:"like open_macro", macro_type: :remote)
          expect(actual.steps).to eq([:x])
          expect(actual.name).to eq(:"like open_macro")
        end

        it do
          actual = ProconBypassMan::Procon::MacroRegistry.load(:"like open_macro", macro_type: :normal)
          expect(actual.steps).to eq([])
          expect(actual.name).to eq(:null)
        end
      end

      context 'macro_typeを未指定' do
        it do
          actual = ProconBypassMan::Procon::MacroRegistry.load(:"like open_macro")
          expect(actual.steps).to eq([])
          expect(actual.name).to eq(:null)
        end
      end
    end
  end
end
