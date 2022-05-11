require "spec_helper"

describe ProconBypassMan::DeviceConnection::OutputReportReminder do
  let(:status) { described_class.new }

  describe '#byte_of' do
    subject { status.byte_of(step: step) }

    context 'enable_player_light' do
      let(:step) { :enable_player_light }

      it { expect(subject).to eq("010000000000000000003001") }
    end

    context 'disable_player_light' do
      let(:step) { :disable_player_light }

      it { expect(subject).to eq("010000000000000000003000") }
    end

    context '#enable_home_button_light' do
      let(:step) { :enable_home_button_light }

      it { expect(subject).to eq("010000000000000000003801") }
    end

    context '#disable_home_button_light' do
      let(:step) { :disable_home_button_light }

      it { expect(subject).to eq("010000000000000000003800") }
    end
  end

  describe '#received?' do
    before do
      status.mark_as_send(step: step)
    end

    subject { status.received?(step: step) }

    context 'enable_player_light' do
      let(:step) { :enable_player_light }

      context 'not received' do
        it { expect(subject).to eq(false) }
      end

      context 'did receive' do
        let(:raw_data) { ["2143810080007cb878903870098030"].pack("H*") }
        before { status.receive(raw_data: raw_data) }
        it { expect(subject).to eq(true) }
      end
    end

    context 'disable_player_light' do
      let(:step) { :disable_player_light }

      context 'not received' do
        it { expect(subject).to eq(false) }
      end

      context 'did receive' do
        let(:raw_data) { ["2143810080007cb878903870098030"].pack("H*") }
        before { status.receive(raw_data: raw_data) }
        it { expect(subject).to eq(true) }
      end

      context '異なるデータを受け取ったとき' do
        let(:raw_data) { ["2143810080007cb878903870098038"].pack("H*") }
        before { status.receive(raw_data: raw_data) }
        it { expect(subject).to eq(false) }
      end
    end
  end

  describe '#has_unreceived_command?' do
    let(:step) { :enable_player_light }

    subject { status.has_unreceived_command? }

    context '初期状態' do
      it { expect(subject).to eq(false) }
    end

    context '送信直後' do
      before do
        status.mark_as_send(step: step)
      end
      it { expect(subject).to eq(true) }
    end

    context '受信した後' do
      let(:raw_data) { ["2143810080007cb878903870098030"].pack("H*") }
      before do
        status.mark_as_send(step: step)
        status.receive(raw_data: raw_data)
      end
      it { expect(subject).to eq(false) }
    end
  end

  describe '#unreceived_byte' do
    let(:step) { :enable_player_light }

    subject { status.unreceived_byte }

    context '初期状態' do
      it { expect { subject }.to raise_error(RuntimeError) }
    end

    context '送信直後' do
      before do
        status.mark_as_send(step: step)
      end
      it { expect(subject).to eq("010000000000000000003001") }
    end

    context '受信した後' do
      let(:raw_data) { ["2143810080007cb878903870098030"].pack("H*") }
      before do
        status.mark_as_send(step: step)
        status.receive(raw_data: raw_data)
      end
      it { expect { subject }.to raise_error(RuntimeError) }
    end
  end

  describe '#receive' do
    let(:step) { :enable_home_button_light }

    before do
      status.mark_as_send(step: step)
    end

    subject { status.receive(raw_data: raw_data);  }

    context '異なるデータを受け取ったとき' do
      let(:raw_data) { ["2143810080007cb878903870098030"].pack("H*") }
      before do
        status.receive(raw_data: raw_data)
      end
      it { expect(subject).to eq(false) }
    end
  end
end
