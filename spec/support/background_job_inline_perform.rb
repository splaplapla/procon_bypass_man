class BackgroundJobInlinePerform
  def self.run
    yield

    loop do
      break if ProconBypassMan::Background::JobRunner.queue.empty?
      job = ProconBypassMan::Background::JobRunner.queue.pop
      job[:reporter_class].perform(*job[:args])
    end
  end
end
