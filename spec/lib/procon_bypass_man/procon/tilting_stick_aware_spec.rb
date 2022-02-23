require "spec_helper"

describe ProconBypassMan::TiltingStickAware do
  context 'スティックを傾けるとき' do
    it do
      report = {:power=>668.242084, :max=>{:x=>-1398, :y=>-365}, :min=>{:x=>-752, :y=>-194}}
      expect(described_class.tilting?(report)).to eq(true)
    end
  end

  context 'スティックを戻すとき' do
    it do
      report = {:power=>1069.9772189999999, :max=>{:x=>-1025, :y=>-464}, :min=>{:x=>-21, :y=>-51}}
      expect(described_class.tilting?(report)).to eq(false)
    end
  end
end
