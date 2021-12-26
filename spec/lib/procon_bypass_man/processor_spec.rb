require "spec_helper"

describe ProconBypassMan::Processor do
  let(:binary) { [data].pack("H*") }

  describe '#process' do
    context 'not binaryがボタン入力の時' do
      let(:data) { "20778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }

      it do
        ProconBypassMan.buttons_setting_configure do
          prefix_keys_for_changing_layer [:zr]
          layer :up do
            disable [:y]
          end
        end

        actual = described_class.new(
          ProconBypassMan::Domains::InboundProconBinary.new(binary: binary)
        ).process
        expect(ProconBypassMan::Procon).not_to receive(:new)
        expect(actual.encoding.to_s).to eq("ASCII-8BIT")
      end
    end

    context 'binaryがボタン入力の時' do
      let(:data) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }

      it do
        ProconBypassMan.buttons_setting_configure do
          prefix_keys_for_changing_layer [:zr]
          layer :up do
            disable [:y]
          end
        end

        actual = described_class.new(
          ProconBypassMan::Domains::InboundProconBinary.new(binary: binary)
        ).process
        expect(actual.encoding.to_s).to eq("ASCII-8BIT")
      end
    end
  end
end
