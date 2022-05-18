require "spec_helper"

describe ProconBypassMan::DeviceConnection::ProconSettingOverrider do
  let(:instance) { described_class.new(procon: procon) }

  describe '#execute!' do
    let(:procon) { nil }

    subject { instance.execute! }

    context 'loopの終了条件がtrueになるとき' do
      let(:output_report_watcher) { ProconBypassMan::DeviceConnection::SpoofingOutputReportWatcher.new(expected_sub_commands: [["38", "01"]]) }

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

    context 'ProconBypassMan.config.enable_home_led_on_connectが無効なとき' do
      before do
        ProconBypassMan.config.enable_home_led_on_connect = false
        allow(instance).to receive(:send_procon)
        allow(instance).to receive(:non_blocking_read_procon).and_return(
          ["21"].pack("H*"),
          ["21"].pack("H*"),
        )
      end

      it do
        expect(instance).not_to receive(:override_setting_by_step)
        expect { instance_run_once }.not_to raise_error

        expect(instance).not_to receive(:re_override_setting_by_cmd)
        expect { instance_run_once }.not_to raise_error
      end
    end

    context 'ProconBypassMan.config.enable_home_led_on_connectが有効なとき' do
      before do
        ProconBypassMan.config.enable_home_led_on_connect = true
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
          expect(instance).to receive(:re_override_setting_by_cmd).and_call_original
          expect { instance_run_once }.not_to raise_error
          expect { instance_run_once }.not_to raise_error
        end
      end

      context '2回目でレスポンスが返ってくるとき' do
        before do
          allow(instance).to receive(:non_blocking_read_procon).and_return(
            ["21"].pack("H*"),
            ["214d810080004c2876a458720b803800000"].pack("H*"),
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
end
