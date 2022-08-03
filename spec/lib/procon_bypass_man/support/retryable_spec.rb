require "spec_helper"

describe ProconBypassMan::Retryable do
  describe '.retryable' do
    it do
      expect {
        ProconBypassMan::Retryable.retryable(tries: 3) { raise }
      }.to raise_error(RuntimeError)
    end

    context '2回目で成功するとき' do
      it do
        expect {
          ProconBypassMan::Retryable.retryable(tries: 3) do |retried|
            raise if retried < 1
          end
        }.not_to raise_error
      end
    end

    context 'on_no_retryに入っている例外が起きたとき' do
      it 'retryしない' do
        expect {
          ProconBypassMan::Retryable.retryable(tries: 3, on_no_retry: [RuntimeError]) do |retried|
            expect(retried).to eq(0)
            raise
          end
        }.to raise_error(RuntimeError)
      end
    end
  end
end
