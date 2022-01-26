require "spec_helper"

describe ProconBypassMan::Procon::ModeRegistry do
  before(:each) { ProconBypassMan::Procon::ModeRegistry.reset! }
  describe '.load' do
    it do
      module Hoge2Mode
        def self.name
          :hoge
        end

        def self.binaries
          [:a, :b, :y]
        end
      end
      ::ProconBypassMan::Procon::ModeRegistry.install_plugin(Hoge2Mode)
      mode = ProconBypassMan::Procon::ModeRegistry.load(:Hoge2Mode)
      expect(mode.next_binary).to eq(:a)
      expect(mode.next_binary).to eq(:b)
      expect(mode.next_binary).to eq(:y)
      expect(mode.next_binary).to eq(:a)
    end
  end
  describe '.install_plugin' do
    it do
      module HogeMode
        def self.name
          :hoge
        end

        def self.binaries
          [:a]
        end
      end
      ::ProconBypassMan::Procon::ModeRegistry.install_plugin(HogeMode)
      expect(ProconBypassMan::Procon::ModeRegistry.plugins.keys).to eq([:HogeMode])
      expect(ProconBypassMan::Procon::ModeRegistry.plugins[:HogeMode].call).to eq([:a])
      expect(ProconBypassMan::Procon::ModeRegistry.load(:HogeMode)).to be_a(ProconBypassMan::Procon::ModeRegistry::Mode)
    end
  end
end
