module ProconBypassMan::DeviceConnection::ProconLess
  class OutputReportWatcher
    # @param [Array<String, Regexp>] watch_targets
    def initialize(watch_targets)
      @watching_table = watch_targets.reduce({}) { |a, x|
        a[x] = false
        next(a)
      }
    end

    # @return [void]
    def mark(raw_data: )
      output_report = OutputReportParser.parse(raw_data: raw_data)
      @watching_table.dup.each do |watching_command, _value|
        if watching_command =~ output_report.to_s
          @watching_table[watching_command] = true
          break
        end
      end
    end

    # @return [Boolean]
    def complete?
      @watching_table.values.all?
    end
  end
end
