require "spec_helper"

describe ProconBypassMan::NeverExitAccidentally do
  let(:klass) do
    Class.new do
      def self.eternal_sleep
      end
    end
  end

  before do
    klass.extend(described_class)
  end

  describe '.exit_if_allow' do
    subject { klass.exit_if_allow(1) }

    context 'when never_exit_accidentally is true' do
      before do
        allow(ProconBypassMan).to receive(:never_exit_accidentally) { true }
      end

      it do
        expect(klass).to receive(:eternal_sleep)
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
