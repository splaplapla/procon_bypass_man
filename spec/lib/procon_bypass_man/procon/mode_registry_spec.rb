require "spec_helper"

describe ProconBypassMan::Procon::ModeRegistry do
  before(:each) { ProconBypassMan::Procon::ModeRegistry.reset! }
  describe '.install_plugin' do
    it do
      module HogeMode
        def self.mode_name
          :hoge
        end

        def self.binaries
          [:a]
        end
      end
      ::ProconBypassMan::Procon::ModeRegistry.install_plugin(HogeMode)
      expect(ProconBypassMan::Procon::ModeRegistry.plugins).to eq(hoge: [:a])
      expect(ProconBypassMan::Procon::ModeRegistry.load(:hoge)).to be_a(ProconBypassMan::Procon::ModeRegistry::Mode)
    end
  end
end
