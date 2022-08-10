class BackgroundJobInlinePerform
  def self.run
    yield

    loop do
      break if ProconBypassMan::Background::JobQueue.size == 0
      job = ProconBypassMan::Background::JobQueue.pop
      job[:reporter_class].perform(*job[:args])
    end
  end
end
