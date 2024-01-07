require "spec_helper"

describe ProconBypassMan::Procon::ModeRegistry2 do
  let(:instance) { described_class.new }

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
      instance.install_plugin(Hoge2Mode)
      mode = instance.load(:Hoge2Mode)
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
      instance.install_plugin(HogeMode)
      expect(instance.plugins.keys).to eq([:HogeMode])
      expect(instance.plugins[:HogeMode].call).to eq([:a])
      expect(instance.load(:HogeMode)).to be_a(ProconBypassMan::Procon::ModeRegistry2::Mode)
    end
  end
end
