# FIXME: RemoteMacroSenderという名前をやめる。BypassProcessSenderみたいにする
class ProconBypassMan::RemoteActionSender
  def self.execute(name: , uuid: , steps: , type: )
    ProconBypassMan.logger.info "[remote macro][sender] name: #{name}, uuid: #{uuid}, steps: #{steps}, type: #{type}"
    ProconBypassMan::RemoteAction::QueueOverProcess.push(
      ProconBypassMan::RemoteAction::Task.new(name, uuid, steps, type)
    )
  end
end
