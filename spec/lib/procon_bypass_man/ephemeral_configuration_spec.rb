require "spec_helper"

describe ProconBypassMan::EphemeralConfiguration do
  let(:instance) { described_class.new }

  describe "#reset!" do
    subject { instance.reset! }

    before do
      instance.enable_rumble_on_layer_change = true
      instance.recognized_procon_color = :red
    end

    it "should reset all values" do
      subject
      expect(instance.enable_rumble_on_layer_change).to be_nil
      expect(instance.recognized_procon_color).to be_nil
    end
  end
end
