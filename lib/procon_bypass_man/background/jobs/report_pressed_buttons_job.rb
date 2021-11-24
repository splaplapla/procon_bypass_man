class ProconBypassMan::ReportPressedButtonsJob < ProconBypassMan::BaseJob
  extend ProconBypassMan::HasInternalApiSetting

  # @param [String] body
  def self.perform(body)
    ProconBypassMan::Background::HttpClient.new(
      path: path,
      pool_server: pool_server,
    ).post(body: body, event_type: :internal)
  end

  def self.path
    "/api/pressed_buttons"
  end
end
