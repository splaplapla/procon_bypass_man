require "spec_helper"

describe OutputReportGenerator do
  describe '#execute' do
    subject(:execute) { OutputReportGenerator.new(*pressed_buttons).execute }

    let(:actual) { [execute].pack("H*") }

    context '引数なし' do
      let(:pressed_buttons) { [] }

      it do
        expect(ProconBypassMan::Procon.new(actual).pressing).to eq([])
      end
    end

    context 'a' do
      let(:pressed_buttons) { [:a] }

      it do
        expect(ProconBypassMan::Procon.new(actual).pressing).to eq([:a])
      end
    end

    context ':zr' do
      let(:pressed_buttons) { [:zr] }

      it do
        expect(ProconBypassMan::Procon.new(actual).pressing).to match_array([:zr])
      end
    end

    context 'a, b, l' do
      let(:pressed_buttons) { [:a, :b, :l] }

      it do
        expect(ProconBypassMan::Procon.new(actual).pressing).to match_array([:a, :b, :l])
      end
    end

    context ':r, :right, :l, :zl, :zl' do
      let(:pressed_buttons) { [:r, :right, :l, :zl, :zr] }

      it do
        expect(ProconBypassMan::Procon.new(actual).pressing).to match_array([:r, :right, :l, :zl, :zr])
      end
    end
  end
end
