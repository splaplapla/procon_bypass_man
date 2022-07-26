require "spec_helper"

describe ProconBypassMan::Bypass::ProconToSwitch do
  describe '.run' do
    let(:binary) { [data].pack("H*") }
    let(:data) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }
    let(:device) { File.open("/dev/null") }
    let(:instance) { described_class.new(gadget: device, procon: device) }

    subject { instance.run }

    before do
      allow(ProconBypassMan::SendErrorCommand).to receive(:execute)
    end

    before do
      allow(instance).to receive(:start_procon_binary_thread)
      instance.procon_binary_queue.push(data)
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

      context 'switchへの書き込みが成功するとき' do
        it { expect(subject).to eq(true) }
        it do
          expect{ subject}.to change { ProconBypassMan::Procon::PerformanceMeasurement::SpanTransferBuffer.instance.send(:spans).size }.by(1)
        end
      end

      context 'switchへの書き込みが失敗するとき(Errno::ETIMEDOUT)' do
        before do
          allow(device).to receive(:write_nonblock) { raise Errno::ETIMEDOUT }
        end

        it { expect(subject).to eq(false) }
      end

      context 'switchへの書き込みが失敗するとき(IO::EAGAINWaitReadable)' do
        before do
          allow(device).to receive(:write_nonblock) { raise IO::EAGAINWaitReadable }
        end

        it { expect(subject).to eq(false) }
      end

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
