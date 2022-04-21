require "spec_helper"

describe ProconBypassMan::DeviceMouseFinder do
  let(:instance) { described_class.new }
  describe '.find' do
    before do
      allow(instance).to receive(:shell_output) { shell_output }
    end

    subject { instance.find }

    context 'mouseが刺さっている場合' do
      let(:shell_output) do
        <<~EOH
I: Bus=0003 Vendor=057e Product=2009 Version=0111
N: Name="Nintendo Co., Ltd. Pro Controller"
P: Phys=usb-0000:01:00.0-1.1/input0
S: Sysfs=/devices/platform/scb/fd500000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0/usb1/1-1/1-1.1/1-1.1:1.0/0003:057E:2009.0001/input/input0
U: Uniq=000000000001
H: Handlers=event0 js0
B: PROP=0
B: EV=1b
B: KEY=3 0 0 0 0 0 0 0 0 0 0 0 0 ffff 0 0 0 0 0 0 0 0 0
B: ABS=30027
B: MSC=10

I: Bus=0003 Vendor=093a Product=2510 Version=0111
N: Name="PixArt USB Optical Mouse"
P: Phys=usb-0000:01:00.0-1.3/input0
S: Sysfs=/devices/platform/scb/fd500000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0/usb1/1-1/1-1.3/1-1.3:1.0/0003:093A:2510.0002/input/input1
U: Uniq=
H: Handlers=mouse0 event1
B: PROP=0
B: EV=17
B: KEY=70000 0 0 0 0 0 0 0 0
B: REL=903
B: MSC=10

I: Bus=0003 Vendor=05ac Product=0267 Version=0110
N: Name="Apple Inc. Magic Keyboard"
P: Phys=usb-0000:01:00.0-1.4/input1
S: Sysfs=/devices/platform/scb/fd500000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0/usb1/1-1/1-1.4/1-1.4:1.1/0003:05AC:0267.0007/input/input3
U: Uniq=F0T908400EAJ20TAA
H: Handlers=sysrq kbd leds event2
B: PROP=0
B: EV=120013
B: KEY=10000 0 0 0 0 0 0 1007b 11007 ff9f217a c14057ff ffbeffdf ffefffff ffffffff fffffffe
B: MSC=10
B: LED=1f

        EOH
      end

      it { is_expected.to eq("/dev/input/event1") }
    end

    context 'mouseが刺さっていない場合' do
      let(:shell_output) do
        <<~EOH
I: Bus=0003 Vendor=057e Product=2009 Version=0111
N: Name="Nintendo Co., Ltd. Pro Controller"
P: Phys=usb-0000:01:00.0-1.1/input0
S: Sysfs=/devices/platform/scb/fd500000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0/usb1/1-1/1-1.1/1-1.1:1.0/0003:057E:2009.0001/input/input0
U: Uniq=000000000001
H: Handlers=event0 js0
B: PROP=0
B: EV=1b
B: KEY=3 0 0 0 0 0 0 0 0 0 0 0 0 ffff 0 0 0 0 0 0 0 0 0
B: ABS=30027
B: MSC=10

        EOH
      end

      it { is_expected.to eq(nil) }
    end

    context 'keyboardが刺さっている場合' do
      let(:shell_output) do
        <<~EOH
I: Bus=0003 Vendor=05ac Product=0267 Version=0110
N: Name="Apple Inc. Magic Keyboard"
P: Phys=usb-0000:01:00.0-1.4/input1
S: Sysfs=/devices/platform/scb/fd500000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0/usb1/1-1/1-1.4/1-1.4:1.1/0003:05AC:0267.0007/input/input3
U: Uniq=F0T908400EAJ20TAA
H: Handlers=sysrq kbd leds event2
B: PROP=0
B: EV=120013
B: KEY=10000 0 0 0 0 0 0 1007b 11007 ff9f217a c14057ff ffbeffdf ffefffff ffffffff fffffffe
B: MSC=10
B: LED=1f

        EOH
      end

      it { is_expected.to eq(nil) }
    end

    context 'デバイスが何も刺さっていない場合' do
      let(:shell_output) { "\n" }
      it do
      end

      it { is_expected.to eq(nil) }
    end
  end
end
