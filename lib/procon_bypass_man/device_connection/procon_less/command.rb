class ProconBypassMan::DeviceConnection::ProconLess::Command
  # @return [void]
  def self.execute
    new.execute
  end

  # @return [void]
  # @raise [ProconBypassMan::SafeTimeout::Timeout]
  def execute
    pre_bypass_first
    pre_bypass
  end

  private

  def pre_bypass_first
    output_report_watcher = OutputReportWatcher.new([
      /^0000/,
      /^0000/,
      /^8005/,
      /^0000/,
      /^8001/,
      /^8002/,
      /^01000000000000000000033/,
      /^8004/,
    ])
    negotiator = ReportNegotiator.new(output_report_watcher: output_report_watcher)
    negotiator.execute
  end

  def pre_bypass
    output_report_watcher = OutputReportWatcher.new([
      "01-04",
      "02-",
      "04-00",
      "08-00",
      "10-00",
      "10-50",
      "10-80",
      "10-98",
      "10-10",
      "30-",
      "40-",
      "48-",
    ])
    negotiator = ReportNegotiator.new(output_report_watcher: output_report_watcher)
    negotiator.execute
  end
end
