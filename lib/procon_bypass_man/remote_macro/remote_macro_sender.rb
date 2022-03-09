class ProconBypassMan::RemoteMacroSender
  def self.execute(action: , uuid: , steps: )
    ProconBypassMan.logger.info "[remote macro] action: #{action}, uuid: #{uuid}, steps: #{steps}"
    nil
    # ProconBypassMan::QueueOverProcess
  end
end
