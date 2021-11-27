class ProconBypassMan::ReportPressedButtonsJob < ProconBypassMan::BaseJob
  extend ProconBypassMan::HasInternalApiSetting

  # @param [String] body
  def self.perform(body)
    ProconBypassMan::ReportHttpClient.new(
      path: path,
      server_pool: server_pool,
    ).post(body: body, event_type: :internal)
  end

  def self.path
    "/api/pressed_buttons"
  end
end
