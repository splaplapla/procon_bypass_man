require "spec_helper"

describe ProconBypassMan::RemoteAction::RemotePbmJob::ReportProconStatusAction do
  describe '#run!' do
    let(:action) { described_class.new(pbm_job_uuid: "a") }
    subject { action.run!(job_args: {}) }

    context 'エラーが起きないとき' do
      before do
        ProconBypassMan::ProconDisplay::Status.instance.current = { test: 1 }
      end

      it do
        expect(action).to receive(:be_processed)
        expect(action).to receive(:be_in_progress)
        expect(action).not_to receive(:be_failed)
        subject
      end
    end
  end
end
