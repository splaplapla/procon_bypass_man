class ProconBypassMan::ReportBaseJob < ProconBypassMan::BaseJob
  def self.path
    "/api/events".freeze
  end
end
