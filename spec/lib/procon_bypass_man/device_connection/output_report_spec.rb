require "spec_helper"

describe ProconBypassMan::DeviceConnection::OutputReport do
  let(:binary) { [data].pack("H*") }
  let(:data) { "01030000000000000000480100000000000000" }

  let(:instance) { ProconBypassMan::DeviceConnection::OutputReport.new(binary: binary) }

  describe '#binary' do
    subject { instance.binary }


    context '0103...' do
      let(:data) { "01030000000000000000480100000000000000" }
      context 'disable_if_rubble_data実行後' do
        before do
          instance.disable_if_rubble_data
        end

        it do
          expect(subject.unpack('H*').first).to eq("01030000000000000000480000000000000000")
        end
      end

      it do
        expect(subject.unpack('H*').first).to eq(data)
      end
    end

    context '0104...' do
      let(:data) { "01040001404000014040480100000000000000000000000000000000" }
      context 'disable_if_rubble_data実行後' do
        before do
          instance.disable_if_rubble_data
        end

        it do
          expect(subject.unpack('H*').first).to eq("01040001404000014040480000000000000000000000000000000000")
        end
      end

      it do
        expect(subject.unpack('H*').first).to eq(data)
      end
    end
  end
end
