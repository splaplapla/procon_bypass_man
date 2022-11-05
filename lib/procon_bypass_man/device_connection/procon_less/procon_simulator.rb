class ProconBypassMan::DeviceConnection::ProconLess::ProconSimulator
  class ReportNegotiator
    def initialize(output_report_watcher: )
      @input_report_builder = InputReportBuilder.new
      @gadget = gadget
      @output_report_watcher = output_report_watcher
    end

    def execute
      loop do
        raw_data = read_from_gadget
        @output_report_watcher.mark(raw_data: raw_data)
        write_to_gadget(@input_report_builder.build(raw_data: raw_data))
        break if @output_report_watcher.complete?
      end
    end
  end

  def self.connect
    new.connect
  end

  # @raise [ProconBypassMan::SafeTimeout::Timeout]
  def connect
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
