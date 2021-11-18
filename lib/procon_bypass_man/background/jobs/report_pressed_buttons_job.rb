class ProconBypassMan::ReportPressedButtonsJob
  extend ProconBypassMan::Background::HasServerPool
  extend ProconBypassMan::Background::JobRunnable

  PATH = "/api/pressed_buttons"

  # @param [String] body
  def self.perform(body)
    ProconBypassMan::Background::HttpClient.new(
      path: PATH,
      pool_server: pool_server,
    ).post(body: body, event_type: :internal)
  end

  def self.servers
    ProconBypassMan.config.internal_api_servers
  end
end
