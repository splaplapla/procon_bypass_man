class ProconBypassMan::SendWarningCommand
  # @param [String, Hash, Exception] warning
  # @return [void]
  def self.execute(warning: , stdout: true)
    body =
      case warning
      when String, Hash
        warning
      else
        warning.full_message
      end

    ProconBypassMan.logger.warn body
    puts body if stdout

    ProconBypassMan::ReportWarningJob.perform(warning)
  end
end
