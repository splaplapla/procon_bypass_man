require "spec_helper"

describe ProconBypassMan::DeviceConnection::OutputReportObserver do
  def to_raw(data)
    [data].pack("H*")
  end

  let(:report_observer) { described_class.new }

  describe '' do
    xit do
      loop do
        # switch -> procon
        raw_data = read_from
        report_observer.mark_as_send(raw_data)
        send_procon(raw_data)

        # procon -> switch
        5.times do
          raw_data = read_procon
          report_observer.mark_as_receive(raw_data)
        end

        if report_observer.completed?
          break
        end
      end
    end
  end


  describe '#sent?' do
    context 'ignoreしている' do
      it do
        expect(report_observer.sent?(sub_command: "48", sub_command_arg: "01")).to eq(true)
      end
    end

    context 'ignoreしていない' do
      it do
        expect(report_observer.sent?(sub_command: "48", sub_command_arg: "00")).to eq(false)
      end
    end
  end

  describe '#mark_as_send' do
    context 'ignore' do
      it do
        report_observer.mark_as_send(to_raw("0109000000000000000048010000"))
        expect(report_observer.sent?(sub_command: "48", sub_command_arg: "01")).to eq(true)
      end
    end

    context 'not ignore' do
      it do
        report_observer.mark_as_send(to_raw("0109000000000000000048000000"))
        expect(report_observer.sent?(sub_command: "48", sub_command_arg: "00")).to eq(true)
      end
    end
  end

  describe '#mask_as_receive' do
    it do
      report_observer.mark_as_send(to_raw("010000000000000000003001"))
      report_observer.mask_as_receive(to_raw("2143810080007cb878903870098030"))
    end
  end

  shared_examples '入力と出力の突き合わせができること' do
    it do
      report_observer.mark_as_send(output_report)
      report_observer.mask_as_receive(input_report)
      expect(report_observer.received?(sub_command: sub_command, sub_command_arg: sub_command_arg)).to eq(true)
    end
    it do
      report_observer.mark_as_send(output_report)
      expect(report_observer.received?(sub_command: sub_command, sub_command_arg: sub_command_arg)).to eq(false)
    end
    it do
      report_observer.mark_as_send(output_report)
      expect(report_observer.sent?(sub_command: sub_command, sub_command_arg: sub_command_arg)).to eq(true)
    end
    it { expect(report_observer.sent?(sub_command: sub_command, sub_command_arg: sub_command_arg)).to eq(false) }
    it { expect(report_observer.received?(sub_command: sub_command, sub_command_arg: sub_command_arg)).to eq(false) }
  end

  describe '30: player light' do
    include_examples '入力と出力の突き合わせができること'

    let(:sub_command) { "30" }
    let(:sub_command_arg) { "01" }
    let(:output_report) { to_raw("010000000000000000003001") }
    let(:input_report) { to_raw("2143810080007cb878903870098030") }
  end

  describe '40-01: Enable IMU (6-Axis sensor)' do
    include_examples '入力と出力の突き合わせができること'

    let(:sub_command) { "40" }
    let(:sub_command_arg) { "01" }
    let(:output_report) { to_raw("0107000000000000000040010000") }
    let(:input_report) { to_raw("213881008000a4f8775b587101804000000000000") }
  end

  describe '10-02:  SPI flash read' do
    include_examples '入力と出力の突き合わせができること'

    let(:sub_command) { "10" }
    let(:sub_command_arg) { "28" }
    let(:output_report) { to_raw("010600000000000000001028800000180000000") }
    let(:input_report) { to_raw("212d81008000a6d8775b68710190102880000018eefea9004602004000400040f7fffdff0900e73be73be73b00") }
  end
end
