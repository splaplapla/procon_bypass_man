module ProconBypassMan::DeviceConnection::ProconLess
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
end
