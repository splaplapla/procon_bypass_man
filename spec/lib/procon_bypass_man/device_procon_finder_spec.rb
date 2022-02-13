require "spec_helper"

describe ProconBypassMan::DeviceProconFinder do
  let(:instance) { described_class.new }

  describe '#find' do
    subject { instance.find }

    context 'proconがあるとき' do
      before do
        allow(instance).to receive(:shell_output) do
          <<~EOH
            hidraw0   Kinesis Advantage2 Keyboard
            hidraw1   Kinesis Advantage2 Keyboard
            hidraw2   Kinesis Advantage2 Keyboard
            hidraw3   Nintendo Co., Ltd. Pro Controller
          EOH
        end
      end

      it do
        expect(subject).to eq("/dev/hidraw3")
      end
    end

    context 'proconがないとき' do
      before do
        allow(instance).to receive(:shell_output) do
          <<~EOH
            hidraw0   Kinesis Advantage2 Keyboard
            hidraw1   Kinesis Advantage2 Keyboard
            hidraw2   Kinesis Advantage2 Keyboard
          EOH
        end
      end

      it do
        expect(subject).to be_nil
      end
    end
  end
end
