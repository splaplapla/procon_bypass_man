class ProconBypassMan::PrintMessageCommand
  # @return [void]
  # @param [String] text
  def self.execute(text: )
    ProconBypassMan.logger.info text
    puts text
  end
end
