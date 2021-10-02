class ProconBypassMan::BypassMutex
  def initialize
    @mutex = Mutex.new
    @lockable = false
  end

  def synchronize(&block)
    raise "need block!!!!" unless block_given?

    if lockable?
      @mutex.synchronize(&block)
    else
      block.call
    end
  end

  def lockable!
    @lockable = true
  end

  private

  def lockable?
    @lockable
  end
end
