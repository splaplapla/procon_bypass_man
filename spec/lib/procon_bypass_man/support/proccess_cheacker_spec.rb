require "spec_helper"

describe ProconBypassMan::ProcessChecker do
  describe '.running?' do
    subject { described_class.running?(pid) }

    context '存在するpidのとき' do
      let(:pid) { $$ }

      it do
        expect(subject).to eq(true)
      end
    end

    context '存在しないpidのとき' do
      let(:pid) { 999999999 }

      it do
        expect(subject).to eq(false)
      end
    end
  end
end
