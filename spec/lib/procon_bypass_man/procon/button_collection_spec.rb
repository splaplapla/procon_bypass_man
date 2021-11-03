require "spec_helper"

describe ProconBypassMan::Procon::ButtonCollection do
  describe 'BUTTONS' do
    it do
      expect(ProconBypassMan::Procon::ButtonCollection::BUTTONS).to eq(
        [:y, :x, :b, :a, :sl, :sr, :r, :zr, :minus, :plus, :thumbr, :thumbl, :home, :cap, :down, :up, :right, :left, :l, :zl]
      )
    end
  end
end
