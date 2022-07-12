class ProconBypassMan::Bypass::ConcurrentBypassExecutor
  CONCURRENT = 2

  attr_accessor :queue, :threads

  def initialize
    @queue = Queue.new
    @threads = CONCURRENT.times.map do
      Thread.new do
        task = queue.pop
        task[:block].call
      end
    end
  end

  # TODO Threadで起きた例外をスローしたい
  # @return [Thread]
  def self.execute(&block)
    instance = self.new

    CONCURRENT.times do
      instance.queue.push(block: block)
    end

    instance.threads
  end
end
