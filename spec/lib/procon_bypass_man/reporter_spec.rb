require "spec_helper"

describe ProconBypassMan::Reporter do
  describe '.report' do
    context 'ProconBypassMan.api_serverが設定されていない時' do
      it do
        expect(ProconBypassMan.api_server).to be_nil
        expect { ProconBypassMan::Reporter.report(body: nil) }.not_to raise_error
      end
    end
  end
end
