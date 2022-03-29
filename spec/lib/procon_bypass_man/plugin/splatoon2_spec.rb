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
    expect(ProconBypassMan::Plugin::Splatoon2::Macro::FastReturn.name).to eq('ProconBypassMan::Plugin::Splatoon2::Macro::FastReturn')
    expect(ProconBypassMan::Plugin::Splatoon2::Macro::FastReturn.steps).to eq([:x, :down, :a, :a])
  end

  describe 'sokuwari' do
    it do
      expect(ProconBypassMan::Plugin::Splatoon2::Macro::SokuwariForSplashBomb.name).to eq('ProconBypassMan::Plugin::Splatoon2::Macro::SokuwariForSplashBomb')
      expect(ProconBypassMan::Plugin::Splatoon2::Macro::SokuwariForSplashBomb.steps).to eq([
        :toggle_r_for_0_2sec,
        :toggle_thumbr_for_0_14sec,
        :toggle_thumbr_and_toggle_zr_for_0_34sec,
        :toggle_r_for_1sec,
      ])
    end
  end

  describe 'charge_tansan_bomb' do
    it do
      expect(ProconBypassMan::Plugin::Splatoon2::Macro::ChargeTansanBomb.name).to eq('ProconBypassMan::Plugin::Splatoon2::Macro::ChargeTansanBomb')
      expect(ProconBypassMan::Plugin::Splatoon2::Macro::ChargeTansanBomb.steps).to eq([
        :shake_left_stick_and_toggle_b_for_0_1sec,
      ])
    end
  end
end
