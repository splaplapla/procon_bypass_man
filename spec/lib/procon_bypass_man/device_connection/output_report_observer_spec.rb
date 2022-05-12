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

  describe '10-28:  SPI flash read' do
    include_examples '入力と出力の突き合わせができること'

    let(:sub_command) { "10" }
    let(:sub_command_arg) { "28" }
    let(:output_report) { to_raw("010600000000000000001028800000180000000") }
    let(:input_report) { to_raw("212d81008000a6d8775b68710190102880000018eefea9004602004000400040f7fffdff0900e73be73be73b00") }
  end

  describe '10-3d:  SPI flash read' do
    include_examples '入力と出力の突き合わせができること'

    let(:sub_command) { "10" }
    let(:sub_command_arg) { "3d" }
    let(:output_report) { to_raw("01050000000000000000103d6000001900000000000000000000") }
    let(:input_report) { to_raw("212681008000a7e8775968710190103d60000019db255d4b287bd3955769c872f3f55caeb560ff323232ffffff0000000") }
  end


  describe '10-98:  SPI flash read' do
    include_examples '入力と出力の突き合わせができること'

    let(:sub_command) { "10" }
    let(:sub_command_arg) { "98" }
    let(:output_report) { to_raw("010200000000000000001098600000120000") }
    let(:input_report) { to_raw("211681008000a7d8775a587101901098600000120f30619630f3d41454411554c7799c33366300000000") }
  end

  describe '10-10:  SPI flash read' do
    include_examples '入力と出力の突き合わせができること'

    let(:sub_command) { "10" }
    let(:sub_command_arg) { "10" }
    let(:output_report) { to_raw("01040000000000000000101080000018000000") }
    let(:input_report) { to_raw("211c81008000a7c8775b48710190101080000018ffffffffffffffffffffffffffffffffffffffffffffb2a10000000000000000000000000000000000000000") }
  end

  describe '10-80:  SPI flash read' do
    include_examples '入力と出力の突き合わせができること'

    let(:sub_command) { "10" }
    let(:sub_command_arg) { "80" }
    let(:output_report) { to_raw("0101000000000000000010806000001800") }
    let(:input_report) { to_raw("210a81008000a6d8775a5871019010806000001850fd0000c60f0f30619630f3d41454411554c7799c3336630000000000000000000000000000000000000000") }
  end

  describe '10-80:  SPI flash read' do
    include_examples '入力と出力の突き合わせができること'

    let(:sub_command) { "04" }
    let(:sub_command_arg) { "00" }
    let(:output_report) { to_raw("01000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000") }
    let(:input_report) { to_raw("210081008000a6e8775958710183040000b73a553ab33a0000000000000000000000000000000000000000000000000000000000000000000000000000000000") }
  end

  describe '10-80:  SPI flash read' do
    include_examples '入力と出力の突き合わせができること'

    let(:sub_command) { "03" }
    let(:sub_command_arg) { "30" }
    let(:output_report) { to_raw("010f0001404000014040033000000000000000000000000000000000000000000000000000000000000000000000000000") }
    let(:input_report) { to_raw("21f781008000a6d87757487101800300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000") }
  end


end
