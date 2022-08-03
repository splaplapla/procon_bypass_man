module ProconBypassMan
  class Retryable
    def self.retryable(tries: , retried: 0, on_no_retry: [])
      return yield(retried)
    rescue *on_no_retry
      raise
    rescue
      if tries <= retried
        raise
      else
        retried = retried + 1
        retry
      end
    end
  end
end
