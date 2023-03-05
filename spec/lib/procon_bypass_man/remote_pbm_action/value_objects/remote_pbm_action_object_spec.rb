require "spec_helper"

describe ProconBypassMan::RemotePbmJobObject do
  let(:source_hash) { {"action"=>"reboot_os", "status"=>"queued", "uuid"=>"20f27b6a-f727-4f8e-819b-bb60035d2ebc", "created_at"=>"2021-11-25T00:40:21.705+09:00"} }

  describe 'accessoring' do
    it do
      object = described_class.new(action: source_hash["action"], status: source_hash["status"], uuid: source_hash["uuid"], created_at: source_hash["created_at"], job_args: {})
      expect(object.action).to eq("reboot_os")
      expect(object.uuid).to eq(source_hash["uuid"])
    end
  end

  describe '#validate!' do
    context 'actionが不明なとき' do
      it do
        object = described_class.new(action: "something", status: source_hash["status"], uuid: source_hash["uuid"], created_at: source_hash["created_at"], job_args: {})
        expect { object.validate! }.to raise_error(ProconBypassMan::RemotePbmJobObject::NonSupportAction)
      end
    end

    context 'uuidがnilなとき' do
      it do
        object = described_class.new(action: "something", status: source_hash["status"], uuid: nil, created_at: source_hash["created_at"], job_args: {})
        expect { object.validate! }.to raise_error(ProconBypassMan::RemotePbmJobObject::MustBeNotNilError)
      end
    end
  end
end
