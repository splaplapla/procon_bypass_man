module ProconBypassMan
  class Retryable
    def self.retryable(tries: , retried: 0, on_no_retry: [], log_label: nil, interval_on_retry: 0)
      return yield(retried)
    rescue *on_no_retry
      raise
    rescue => e
      if tries <= retried
        raise
      else
        retried = retried + 1
        ProconBypassMan.logger.debug "[Retryable]#{log_label && "[#{log_label}]"} #{e}が起きました。retryします。#{retried} / #{tries}"

        sleep(interval_on_retry)
        retry
      end
    end
  end
end
