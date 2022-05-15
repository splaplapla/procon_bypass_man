require "spec_helper"

describe ProconBypassMan::DeviceConnection::ProconSettingOverrider do
  let(:instance) { described_class.new(procon: procon) }

  describe '#execute!' do
    let(:procon) { nil }

    subject { instance.execute! }

    context 'loopの終了条件がtrueになるとき' do
      let(:output_report_watcher) { ProconBypassMan::DeviceConnection::SpoofingOutputReportWatcher.new }

      before do
        allow(instance).to receive(:run_once)
        allow(output_report_watcher).to receive(:timeout_or_completed?) { true }
        allow(instance).to receive(:output_report_watcher) { output_report_watcher }
      end

      it { expect { subject }.not_to raise_error }
    end
  end

  describe '#run_once' do
    let(:procon) { nil }

    def instance_run_once
      instance.run_once
    end

    before do
      allow(instance).to receive(:send_procon)
    end

    context '2回目でレスポンスが返ってこないとき' do
      before do
        allow(instance).to receive(:non_blocking_read_procon).and_return(
          ["21"].pack("H*"),
          ["21"].pack("H*"),
        )
      end

      it do
        expect(instance).to receive(:override_setting_by_step).and_call_original
        expect { instance_run_once }.not_to raise_error

        expect(instance).to receive(:re_override_setting_by_cmd).and_call_original
        expect { instance_run_once }.not_to raise_error
      end
    end

    context '2回目でレスポンスが返ってくるとき' do
      before do
        allow(instance).to receive(:non_blocking_read_procon).and_return(
          ["21"].pack("H*"),
          [["21", "0"*26, "3801"].join].pack("H*"),
        )
      end

      it do
        expect(instance).to receive(:override_setting_by_step).and_call_original
        expect { instance_run_once }.not_to raise_error

        expect(instance).not_to receive(:re_override_setting_by_cmd)
        expect { instance_run_once }.not_to raise_error
      end
    end
  end
end
