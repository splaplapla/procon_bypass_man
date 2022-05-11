require "spec_helper"

describe ProconBypassMan::NeverExitAccidentally do
  describe '.exit_if_allow_at_config' do
    subject { described_class.exit_if_allow_at_config }

    context 'when never_exit_accidentally is true' do
      before do
        allow(ProconBypassMan).to receive(:never_exit_accidentally) { true }
      end

      it do
        expect(ProconBypassMan).to receive(:eternal_sleep)
        subject
      end
    end

    context 'when never_exit_accidentally is false' do
      before do
        allow(ProconBypassMan).to receive(:never_exit_accidentally) { false }
      end

      it do
        expect { subject }.to raise_error(SystemExit)
      end
    end
  end
end
