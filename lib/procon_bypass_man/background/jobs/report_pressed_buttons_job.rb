class ProconBypassMan::PressedButtonsReporter
  extend ProconBypassMan::Background::HasRoundRobinServer
  extend ProconBypassMan::Background::JobRunnable

  PATH = "/api/pressed_buttons"

  # @param [String] body
  def self.perform(body)
    ProconBypassMan::Background::HttpClient.new(
      path: PATH,
      server_picker: server_picker,
    ).post(body: body, event_type: :internal)
  end

  def self.servers
    ProconBypassMan.config.internal_api_servers
  end
end
