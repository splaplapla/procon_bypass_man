require "spec_helper"

describe ProconBypassMan::Background::Reporter do
  describe '.push' do
    it do
      class Result < Struct.new(:stats); end
      reporter_class = Class.new do
        def self.report(*); Result.new(true); end
      end
      expect {
        ProconBypassMan::Background::Reporter.push({
          reporter_class: reporter_class,
          data: {},
        })
      }.not_to raise_error
    end
    context '上限までenqueueしたとき' do
      let(:dummy_queue) { [] }
      before do
        101.times { dummy_queue << true }
        allow(ProconBypassMan::Background::Reporter).to receive(:queue) { dummy_queue }
      end
      it do
        expect(ProconBypassMan::Background::Reporter.push(true)).to be_nil
      end
    end
  end
end
