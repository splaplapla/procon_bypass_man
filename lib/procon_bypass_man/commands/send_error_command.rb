class ProconBypassMan::SendErrorCommand
  # @param [String, Hash, Exception] error
  # @return [void]
  def self.execute(error: , stdout: false)
    body =
      case error
      when String, Hash
        error
      else
        error.full_message
      end

    ProconBypassMan.logger.error body
    ProconBypassMan.error_logger.error body
    puts body if not stdout

    ProconBypassMan::ReportErrorJob.perform(error)
  end
end
