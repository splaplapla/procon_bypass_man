require "spec_helper"

describe ProconBypassMan do
  describe '.configure' do
    describe 'layer' do
      it do
        described_class.configure do
          layer :up do
            flip []
          end
          layer :down do
            flip []
          end
          layer :right do
            flip []
          end
          layer :left do
            flip []
          end
        end
        expect(ProconBypassMan::Configuration.instance.layers[:up]).to eq([])
        expect(ProconBypassMan::Configuration.instance.layers[:down]).to eq([])
        expect(ProconBypassMan::Configuration.instance.layers[:right]).to eq([])
        expect(ProconBypassMan::Configuration.instance.layers[:left]).to eq([])
      end
    end
    describe 'prefix_keys_for_changing_layer' do
      it do
        described_class.configure do
          prefix_keys_for_changing_layer [:zr]
        end
        expect(ProconBypassMan::Configuration.instance.prefix_keys).to eq([:zr])
      end
    end
  end
end
