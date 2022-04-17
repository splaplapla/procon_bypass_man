require "spec_helper"

describe ProconBypassMan::SafeTimeout do
  let(:time) { Time.now }
  let(:instance) { ProconBypassMan::SafeTimeout.new(timeout: time + offset) }

  around(:each) do |example|
    Timecop.freeze time do
      example.run
    end
  end

  describe '#throw_if_timeout!' do
    context 'まだ' do
      let(:offset) { 1 }
      it do
        expect { instance.throw_if_timeout! }.not_to raise_error
      end
    end

    context '時間が過ぎている' do
      let(:offset) { -1 }
      it do
        expect { instance.throw_if_timeout! }.to raise_error(ProconBypassMan::SafeTimeout::Timeout)
      end
    end
  end

  describe '#timeout?' do
    context 'まだ' do
      let(:offset) { 1 }
      it do
        expect(instance.timeout?).to eq(false)
      end
    end

    context '時間が過ぎている' do
      let(:offset) { -1 }
      it do
        expect(instance.timeout?).to eq(true)
      end
    end
  end
end
