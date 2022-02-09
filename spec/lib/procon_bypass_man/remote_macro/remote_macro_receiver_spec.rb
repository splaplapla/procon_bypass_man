require "spec_helper"

describe ProconBypassMan::RemoteMacroReceiver do
  describe '.start!' do
    context 'not enable' do
      it do
        expect(described_class.start!).to eq(nil)
      end
    end

    context 'enable' do
      before do
        allow(ProconBypassMan.config).to receive(:enable_remote_macro?) { true }
      end

      it do
        expect { described_class.start! }.not_to raise_error
      end
    end
  end
end
