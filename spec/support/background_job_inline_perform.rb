class BackgroundJobInlinePerform
  def self.run
    yield

    loop do
      break if ProconBypassMan::Background::JobQueue.size == 0
      job = ProconBypassMan::Background::JobQueue.pop
      eval(job[:job_class]).perform(*job[:args])
    end
  end
end
