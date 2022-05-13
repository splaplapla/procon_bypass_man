require "spec_helper"

describe ProconBypassMan::DeviceConnection::PreBypass do
  let(:instance) { described_class.new(procon: procon, gadget: gadget) }

  describe '#execute!' do
    let(:procon) { nil }
    let(:gadget) { nil }

    subject { instance.execute! }

    context 'loopの終了条件がtrueになるとき' do
      let(:output_report_observer) { ProconBypassMan::DeviceConnection::OutputReportObserver.new }

      before do
        allow(instance).to receive(:run_once)
        allow(output_report_observer).to receive(:timeout_or_completed?) { true }
        allow(instance).to receive(:output_report_observer) { output_report_observer }
      end

      it { expect { subject }.not_to raise_error }
    end
  end

  describe '#run_once' do
    let(:procon) { nil }
    let(:gadget) { nil }

    subject { instance.run_once }

    before do
      allow(instance).to receive(:non_blocking_read_switch) { "hoge" }
      allow(instance).to receive(:send_procon)
      allow(instance).to receive(:non_blocking_read_procon) { "hoge" }
      allow(instance).to receive(:send_switch)
    end

      it { expect { subject }.not_to raise_error }
  end
end
