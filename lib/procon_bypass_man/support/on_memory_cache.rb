class ProconBypassMan::OnMemoryCache
  class CacheValue
    # @param [Time]
    attr_accessor :expired_at
    attr_accessor :value

    def initialize(expired_at: , value: )
      self.expired_at = expired_at
      self.value = value
    end
  end

  def initialize
    @table = {}
  end

  # @param [Integer] expires_in 秒数
  # @param [String] key
  def fetch(key: , expires_in: , &block)
    now = Time.now
    if @table[key].nil?
      value = block.call
      value_object = CacheValue.new(expired_at: now + expires_in, value: value)
      @table[key] = value_object
      return value
    end

    if @table[key].expired_at < now
      value = block.call
      @table[key] = CacheValue.new(expired_at: now + expires_in, value: value)
      return value
    else
      return @table[key].value
    end
  end
end
