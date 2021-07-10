class ProconBypassMan::Procon
  class FlipCache
    def self.fetch(key: , expires_in: , &block)
      if expires_in.nil?
        block.call
      else
        @@previous_flips_at_table[key] ||= Time.now
        if @@previous_flips_at_table[key] < Time.now
          @@previous_flips_at_table[key] = Time.now + expires_in
          block.call
        end
      end
    end

    # for testing
    def self.reset!
      @@previous_flips_at_table = {}
    end

    reset!
  end
end
