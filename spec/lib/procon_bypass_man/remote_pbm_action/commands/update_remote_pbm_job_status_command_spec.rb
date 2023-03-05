require "spec_helper"

describe ProconBypassMan::UpdateRemotePbmJobStatusCommand do
  describe '.execute!' do
    let(:post_body) { "hoge" }

    subject { described_class.new(pbm_job_uuid: "a").execute(to_status: 1) }

    it do
      subject
    end
  end
end
