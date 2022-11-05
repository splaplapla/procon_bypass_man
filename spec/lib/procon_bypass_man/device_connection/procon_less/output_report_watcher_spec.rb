require "spec_helper"

describe ProconBypassMan::DeviceConnection::ProconLess::OutputReportWatcher do
  describe '#mark' do
    let(:instance) { described_class.new(reports) }

    describe '#complete?' do
      def to_raw_data(raw_data)
        [raw_data].pack("H*")
      end

      context '一部' do
        let(:reports) { [
          /^0000/,
          /^8004/,
        ] }

        it do
          expect(instance.complete?).to eq(false)
          instance.mark(raw_data: to_raw_data("0000"))
          instance.mark(raw_data: to_raw_data("8004"))
          expect(instance.complete?).to eq(true)
        end
      end

      context '1つ' do
        let(:reports) { [
          /^8004/,
        ] }

        it do
          expect(instance.complete?).to eq(false)
          instance.mark(raw_data: to_raw_data("8004"))
          expect(instance.complete?).to eq(true)
        end
      end

      context '1つ' do
        let(:reports) { [
          /^01-03/,
        ] }

        it do
          expect(instance.complete?).to eq(false)
          instance.mark(raw_data: to_raw_data("01000000000000000000033"))
          expect(instance.complete?).to eq(true)
        end
      end

      context 'pre_bypass' do
        let(:reports) { [
          /^0000/,
          /^0000/,
          /^8005/,
          /^0000/,
          /^8001/,
          /^8002/,
          /^8004/,
        ] }

        it do
          expect(instance.complete?).to eq(false)
          instance.mark(raw_data: to_raw_data("0000"))
          instance.mark(raw_data: to_raw_data("8005"))
          instance.mark(raw_data: to_raw_data("8001"))
          instance.mark(raw_data: to_raw_data("8002"))
          instance.mark(raw_data: to_raw_data("8004"))
          expect(instance.complete?).to eq(true)
        end
      end
    end
  end
end
