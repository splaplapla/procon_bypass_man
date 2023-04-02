require "spec_helper"

describe ProconBypassMan::Bypass::ProconToSwitch do
  describe '.work' do
    let(:binary) { [data].pack("H*") }
    let(:data) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }
    let(:device) {
      file = File.open("/dev/null")
      allow(file).to receive(:read_nonblock) { "" }
      file
    }
    let(:instance) { described_class.new(gadget: device, procon: device) }

    subject { instance.work }

    before do
      allow(ProconBypassMan::SendErrorCommand).to receive(:execute)
      allow(ProconBypassMan::Processor).to receive(:new) { double(:p).as_null_object } # バイナリの加工はしない
      allow(ProconBypassMan::Procon::PerformanceMeasurement).to receive(:is_not_measure_with_random_or_if_fast) { false }

      bypass_value = double(:value)
      allow(bypass_value).to receive(:binary) { ProconBypassMan::Domains::InboundProconBinary.new(binary: binary)  }
      allow(ProconBypassMan::Bypass::BypassValue).to receive(:new) { bypass_value.as_null_object }
      allow(device).to receive(:write_nonblock)
    end

    context 'ProconBypassMan.config.enable_procon_performance_measurement? が無効' do
      before do
        allow(ProconBypassMan.config).to receive(:enable_procon_performance_measurement?) { false }
      end

      it { expect(subject).to be_nil }
    end

    context 'ProconBypassMan.config.enable_procon_performance_measurement? が有効' do
      before do
        allow(ProconBypassMan.config).to receive(:enable_procon_performance_measurement?) { true }
      end

      context 'external_input_dataがあるとき' do
        before do
          allow(ProconBypassMan::ExternalInput).to receive(:read) { external_input_json }
        end

        context 'external_input_dataにゴミが入ってくるとき' do
          let(:external_input_json) {
            252.chr # NOTE: a, bを押している
          }
          it { expect(subject).to eq(true) }
          it 'blue green process上で成功すること' do
            BlueGreenProcess.config.logger = ProconBypassMan.logger
            process = BlueGreenProcess.new(
              worker_instance: instance,
              max_work: 4,
            )
            process.work
            process.work
            process.shutdown
          end
        end

        context 'external_input_dataに想定した文字列が入ってくるとき' do
          let(:external_input_json) {
            { hex: '30f2810c800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000' }.to_json # NOTE: a, bを押している
          }

          it { expect(subject).to eq(true) }
          it 'blue green process上で成功すること' do
            BlueGreenProcess.config.logger = ProconBypassMan.logger
            process = BlueGreenProcess.new(
              worker_instance: instance,
              max_work: 4,
            )
            process.work
            process.work
            process.shutdown
          end
        end
      end

      context 'switchへの書き込みが成功するとき' do
        it { expect(subject).to eq(true) }
        it { expect{ subject }.to change { ProconBypassMan::Procon::PerformanceMeasurement::SpanTransferBuffer.instance.send(:spans).size }.by(1) }

        it 'blue green process上で成功すること' do
          BlueGreenProcess.config.logger = ProconBypassMan.logger
          process = BlueGreenProcess.new(
            worker_instance: instance,
            max_work: 4,
          )
          process.work
          process.work
          process.shutdown
        end
      end

      context 'switchへの書き込みが失敗するとき(Errno::ETIMEDOUT)' do
        before do
          allow(device).to receive(:write_nonblock) { raise Errno::ETIMEDOUT }
        end

        it { expect { subject }.to raise_error(Errno::ETIMEDOUT) }
      end

      context 'switchへの書き込みが失敗するとき(IO::EAGAINWaitReadable)' do
        before do
          allow(device).to receive(:write_nonblock) { raise IO::EAGAINWaitReadable }
        end

        it { expect(subject).to eq(false) }

        # TODO proconからの読み込みで吸収されている.... メソッドを分ける。でも他のブランチと競合するので後でやる
        context '終了フラグが立っている時' do
          before do
            $will_terminate_token = true
          end

          after do
            $will_terminate_token = false
          end

          it { expect(subject).to eq(false) }
        end
      end
    end
  end
end
