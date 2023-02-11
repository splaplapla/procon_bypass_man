class ProconBypassMan::SendInfoLogCommand
  # @param [String] message
  # @return [void]
  def self.execute(message: , stdout: true)
    body = message
    ProconBypassMan.logger.info(body)
    puts body if stdout

    ProconBypassMan::ReportInfoLogJob.perform(body)
  end
end
