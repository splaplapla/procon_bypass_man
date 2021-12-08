require "spec_helper"

describe ProconBypassMan::Plugin::Splatoon2 do
  describe 'version' do
    it do
      expect(ProconBypassMan::Plugin::Splatoon2::VERSION).not_to be_nil
    end
  end

  it do
    expect(ProconBypassMan::Plugin::Splatoon2::Mode::Guruguru.binaries).to be_a(Array)
  end

  it do
    expect(ProconBypassMan::Plugin::Splatoon2::Macro::FastReturn.name).to eq(:fast_return)
    expect(ProconBypassMan::Plugin::Splatoon2::Macro::FastReturn.steps).to eq([:x, :down, :a, :a])
  end
end
