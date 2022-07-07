require "spec_helper"

describe ProconBypassMan::ReportProconPerformanceMeasurementsJob do
  describe '.perform' do
    before do
      ProconBypassMan.configure do |config|
        config.api_servers = ["http://localhost:3000"]
      end
    end

    context 'nilを与えるとき' do
      it do
        http_response = double(:http_response).as_null_object
        expect_any_instance_of(Net::HTTP).not_to receive(:post) { http_response }
        expect { described_class.perform(nil) }.not_to raise_error
      end
    end

    context 'measurement_collectionを与えるとき' do
      it do
        pending
      end
    end
  end
end
