class ProconBypassMan::Procon
  class FlipCache
    def self.fetch(expires_in: , &block)
      if expires_in.nil?
        block.call
      else
        if @@previous_fetch < Time.now
          @@previous_fetch = Time.now + expires_in
        end
      end
    end

    @@previous_fetch = Time.now
  end
end
