class ProconBypassMan::ReportEventBaseJob < ProconBypassMan::BaseJob
  def self.path
    "/api/events".freeze
  end
end
