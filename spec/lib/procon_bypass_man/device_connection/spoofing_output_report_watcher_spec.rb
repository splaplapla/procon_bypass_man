require "spec_helper"

describe ProconBypassMan::DeviceConnection::SpoofingOutputReportWatcher do
  def to_raw(data)
    [data].pack("H*")
  end

  let(:instance) { described_class.new(expected_sub_commands: [["38", "01"]]) }

  describe do
    shared_examples '入力と出力の突き合わせができること' do
      it do
        instance.mark_as_send(output_report)
        instance.mark_as_receive(input_report)
        expect(instance.has_unreceived_command?).to eq(true)
        expect(instance.unreceived_sub_command_with_arg).to eq("#{sub_command}#{sub_command_arg}")
      end
      it do
        instance.mark_as_send(output_report)
        expect(instance.has_unreceived_command?).to eq(true)
      end
      it { expect(instance.has_unreceived_command?).to eq(false) }
    end

    describe '38-01' do
      include_examples '入力と出力の突き合わせができること'

      let(:sub_command) { "38" }
      let(:sub_command_arg) { "F1F" }
      let(:output_report) { to_raw("010200000000000000003801") }
      let(:input_report) { to_raw("213881008000a4f8775b587101804000000000000") }
    end
  end

  describe '#unreceived_sub_command_with_arg' do
    it { expect(instance.unreceived_sub_command_with_arg).to eq(nil) }

    context 'has unreceived that' do
      let(:output_report) { to_raw("010200000000000000003801") }
      it do
        instance.mark_as_send(output_report)
        expect(instance.unreceived_sub_command_with_arg).to eq("38F1F")
      end
    end
  end

  describe '#completed?' do
    subject { instance.completed? }

    context '初期状態' do
      it do
        expect(instance.completed?).to eq(false)
      end
    end

    context '送っただけのとき' do
      before do
        instance.mark_as_send(to_raw("010200000000000000003801"))
      end

      it do
        expect(instance.completed?).to eq(false)
      end
    end

    context '全部receiveしたとき' do
      before do
        instance.mark_as_send(to_raw("010200000000000000003801"))
        instance.mark_as_receive(to_raw(["21", "0"*26, "3801"].join))
      end

      it do
        expect(instance.completed?).to eq(true)
      end
    end
  end
end
