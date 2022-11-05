require "spec_helper"

describe ProconBypassMan::DeviceConnection::ProconLess::OutputReportParser do
  describe '.parse' do
    subject { described_class.parse(raw_data: raw_data) }

    let(:raw_data) { [data].pack("H*") }

    context 'command is not 10' do
      context 'when provides 0000' do
        let(:data) { "0000" }
        it do
          expect(subject).to have_attributes(command: "0000", sub_command_arg: nil)
        end
      end

      context 'when provides 8005' do
        let(:data) { "8005" }
        it do
          expect(subject).to have_attributes(command: data, sub_command_arg: nil)
        end
      end

      context 'when provides 8002' do
        let(:data) { "8002" }
        it do
          expect(subject).to have_attributes(command: data, sub_command_arg: nil)
        end
      end

      context 'when provides 8001' do
        let(:data) { "8001" }
        it do
          expect(subject).to have_attributes(command: data, sub_command_arg: nil)
        end
      end

      context 'when provides 8004' do
        let(:data) { "8004" }
        it do
          expect(subject).to have_attributes(command: data, sub_command_arg: nil)
        end
      end
    end

    context 'command is 10' do
      context 'and sub_command and arg is `10-03`' do
        let(:data) { "01000000000000000000033000000000000000000000000000000000000000000000000000000000000000000000000000" }
        it do
          expect(subject).to have_attributes(command: "01", sub_command: "03", sub_command_arg: nil)
        end
      end

      context 'and sub_command and arg is `02-`' do
        let(:data) { "01010000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000" }
        it do
          expect(subject).to have_attributes(command: "01", sub_command: "02")
        end
      end

      context 'and sub_command and arg is `04-00`' do
        let(:data) { "01070000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000" }
        it do
          expect(subject).to have_attributes(command: "01", sub_command: "04", sub_command_arg: nil)
        end
      end

      context 'and sub_command and arg is `08-00`' do
        let(:data) { "01020000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000" }
        it do
          expect(subject).to have_attributes(command: "01", sub_command: "08", sub_command_arg: nil)
        end
      end
    end
  end
end
