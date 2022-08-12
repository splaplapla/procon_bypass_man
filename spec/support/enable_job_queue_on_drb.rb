RSpec.shared_context 'enable_job_queue_on_drb' do
  before do
    allow(ProconBypassMan::Background::JobQueue).to receive(:enable?) { true }
    ProconBypassMan::Background::JobQueue.start!
  end

  after do
    ProconBypassMan::Background::JobQueue.shutdown
  end
end
