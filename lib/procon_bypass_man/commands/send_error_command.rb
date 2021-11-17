class ProconBypassMan::SendErrorCommand
  # @param [String, Hash, Exception] error
  # @return [void]
  def self.execute(error: )
    body =
      case error
      when String, Hash
        error
      else
        error.full_message
      end

    ProconBypassMan.logger.error body
    puts body

    ProconBypassMan::Outbound::Worker.push(
      body: error,
      reporter_class: ProconBypassMan::ErrorReporter,
    )
  end
end
