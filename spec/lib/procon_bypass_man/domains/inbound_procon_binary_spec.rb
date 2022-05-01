require "spec_helper"

describe ProconBypassMan::Domains::InboundProconBinary do
  let(:binary) { [data].pack("H*") }

  describe '#raw' do
    let(:data) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }

    subject { described_class.new(binary: binary).raw }

    it do
      is_expected.to eq(binary)
    end
  end

  describe '#unpack' do
    let(:data) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }

    subject { described_class.new(binary: binary).unpack }

    it do
      is_expected.to eq([data])
    end
  end

  describe '#to_procon_reader' do
    let(:data) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }

    subject { described_class.new(binary: binary).to_procon_reader }

    it do
      is_expected.to be_a(ProconBypassMan::ProconReader)
    end
  end

  describe '#user_operation_data?' do
    context 'when yes' do
      let(:data) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }

      subject { described_class.new(binary: binary).user_operation_data? }

      it do
        is_expected.to eq(true)
      end
    end
  end

  context 'when no' do
    let(:data) { "20778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }

    subject { described_class.new(binary: binary).user_operation_data? }

    it do
      is_expected.to eq(false)
    end
  end

  describe '#rumble_data?' do
    subject { described_class.new(binary: binary).rumble_data? }

    context 'x10' do
      let(:data) { "100d0001404000014040" }
      it { is_expected.to eq(true) }
    end

    context 'x30' do
      let(:data) { "307781058000" }
      it { is_expected.to eq(false) }
    end
  end
end
