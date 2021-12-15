require "spec_helper"

describe ProconBypassMan::Domains::ProcessingProconBinary do
  let(:binary) { [data].pack("H*") }

  describe '#raw' do
    let(:data) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }

    subject { described_class.new(binary: binary).raw }

    it do
      is_expected.to eq(binary)
    end
  end

  describe '#unpack' do
    let(:data) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }

    subject { described_class.new(binary: binary).unpack }

    it do
      is_expected.to eq([data])
    end
  end

  describe '#set_no_action!' do
    let(:pressed_y_and_b) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }
    let(:data) { pressed_y_and_b }

    subject { o = described_class.new(binary: binary); o.set_no_action!; o }

    it do
      expect(ProconBypassMan::ProconReader.new(binary: binary).pressed).to eq([:y, :b])
      expect(ProconBypassMan::ProconReader.new(binary: subject.raw).pressed).to eq([])
    end
  end

  describe '#write_as_press_button' do
    let(:pressed_y_and_b) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }
    let(:data) { pressed_y_and_b }

    subject { o = described_class.new(binary: binary); o.write_as_press_button(:a); o }

    it do
      expect(ProconBypassMan::ProconReader.new(binary: binary).pressed).to eq([:y, :b])
      expect(ProconBypassMan::ProconReader.new(binary: subject.raw).pressed).to eq([:y, :b, :a])
    end
  end

  describe '#write_as_unpress_button' do
    let(:pressed_y_and_b) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }
    let(:data) { pressed_y_and_b }

    subject { o = described_class.new(binary: binary); o.write_as_unpress_button(:y); o }

    it do
      expect(ProconBypassMan::ProconReader.new(binary: binary).pressed).to eq([:y, :b])
      expect(ProconBypassMan::ProconReader.new(binary: subject.raw).pressed).to eq([:b])
    end
  end

  describe '#write_as_press_button_only' do
    let(:pressed_y_and_b) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }
    let(:data) { pressed_y_and_b }

    subject { o = described_class.new(binary: binary); o.write_as_press_button_only(:x); o }

    it do
      expect(ProconBypassMan::ProconReader.new(binary: binary).pressed).to eq([:y, :b])
      expect(ProconBypassMan::ProconReader.new(binary: subject.raw).pressed).to eq([:x])
    end
  end

  describe '#write_as_merge' do
    let(:pressed_y_and_b) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }
    let(:some_pressed) { "306991c080c4c987734758740af2011c03ef0f5bffe2ffedffe8013403e00f70fff0fff4ffe8014a03cb0f6effeefff2ff000000000000000000000000000000" }

    it do
      pressed_y_and_b_binary = [pressed_y_and_b].pack("H*")
      some_pressed_binary = [some_pressed].pack("H*")
      expect(ProconBypassMan::ProconReader.new(binary: pressed_y_and_b_binary).pressed).to eq([:y, :b])
      expect(ProconBypassMan::ProconReader.new(binary: some_pressed_binary).pressed).to eq([:r, :zr, :right, :l, :zl])

      merged_binary = described_class.new(binary: pressed_y_and_b_binary)
      merged_binary.write_as_merge!(
        described_class.new(binary: some_pressed_binary)
      )
      expected = [:y, :b] + [:r, :zr, :right, :l, :zl]
      expect(ProconBypassMan::ProconReader.new(binary: merged_binary.raw).pressed.sort).to eq(expected.sort)
    end
  end

  describe '#write_as_apply_left_analog_stick_cap' do
    context 'capの範囲内のとき' do
      let(:pressed_y_and_b) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }
      let(:data) { pressed_y_and_b }

      it do
        b = described_class.new(binary: binary)
        b.write_as_apply_left_analog_stick_cap(cap: 1100)
        expect(b.raw).to eq(binary)
      end
    end
  end
end
