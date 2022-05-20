class ProconBypassMan::DeviceConnection::PreBypass
  attr_accessor :gadget, :procon, :output_report_watcher

  def initialize(gadget: , procon: )
    self.gadget = ProconBypassMan::DeviceModel.new(gadget)
    self.procon = ProconBypassMan::DeviceModel.new(procon)
    self.output_report_watcher = ProconBypassMan::DeviceConnection::OutputReportWatcher.new
  end

  # @return [void]
  def execute!
    loop do
      run_once

      if output_report_watcher.timeout_or_completed?
        break
      end
    end
  end

  # @return [void]
  def run_once
    begin
      raw_data = non_blocking_read_switch
      output_report_watcher.mark_as_send(raw_data)
      ProconBypassMan.logger.info "[pre_bypass] >>> #{raw_data.unpack("H*").first}"
      send_procon(raw_data)
    rescue IO::EAGAINWaitReadable
      # no-op
    end

    3.times do
      begin
        raw_data = non_blocking_read_procon
        output_report_watcher.mark_as_receive(raw_data)
        ProconBypassMan.logger.info "[pre_bypass] <<< #{raw_data.unpack("H*").first}"
        send_switch(raw_data)
      rescue IO::EAGAINWaitReadable
        # no-op
      end
    end
  end

  private

  # @raise [IO::EAGAINWaitReadable]
  # @return [String]
  def non_blocking_read_switch
    gadget.non_blocking_read
  end

  # @raise [IO::EAGAINWaitReadable]
  # @return [String]
  def non_blocking_read_procon
    procon.non_blocking_read
  end

  # @return [void]
  def send_procon(raw_data)
    procon.send(raw_data)
  end

  # @return [void]
  def send_switch(raw_data)
    gadget.send(raw_data)
  end
end
