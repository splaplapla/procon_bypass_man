class ProconBypassMan::Bypass::ConcurrentBypassExecutor
  # 1だとブロッキングされた時にラグくなる
  # 3だとIO待ちが増えて効率が悪い
  # TODO IOがブロッキングされた時にすぐにcontextを変えれるならFiberを使った方がリソースの消費は低くなるはず。今度試す
  CONCURRENT = 2

  attr_accessor :queue, :threads

  def initialize
    @queue = Queue.new
    @threads = CONCURRENT.times.map do
      Thread.new do
        # NOTE blockの中でloopを使ってブロッキングしているので、単発の実行でよい
        task = queue.pop
        task[:block].call
      end
    end
  end

  # TODO Threadで起きた例外をスローしたい
  # @return [Arry<Thread>]
  def self.execute(&block)
    instance = self.new

    CONCURRENT.times do
      instance.queue.push(block: block)
    end

    instance.threads
  end
end
