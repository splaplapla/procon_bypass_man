require "spec_helper"

describe ProconBypassMan::Procon::Rumbler do
  describe '.monitor' do
    context 'ブロックの中で何もしないとき' do
      it do
        ProconBypassMan::Procon::Rumbler.monitor {}
        expect(ProconBypassMan::Procon::Rumbler.must_rumble?).to eq(false)
      end
    end

    context 'ブロックの中でrumble!を呼び出すとき' do
      it do
        ProconBypassMan::Procon::Rumbler.monitor {
         ProconBypassMan::Procon::Rumbler.rumble!
        }
        expect(ProconBypassMan::Procon::Rumbler.must_rumble?).to eq(true)
      end
    end
  end
end
