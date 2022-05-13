class ProconBypassMan::DeviceConnection::PreBypass
  attr_accessor :gadget, :procon, :output_report_observer

  def initialize(gadget: , procon: )
    self.gadget = gadget
    self.procon = procon
    self.output_report_observer = ProconBypassMan::DeviceConnection::OutputReportObserver.new
  end

  # TODO 返事が返ってくるまで任意のx01(home led光らせる)をプロコンに送りつける
  # @return [void]
  def execute!
    loop do
      run_once

      if output_report_observer.timeout_or_completed?
        break
      end
    end
  end

  # @return [void]
  def run_once
    begin
      raw_data = non_blocking_read_switch
      output_report_observer.mark_as_send(raw_data)
      ProconBypassMan.logger.info "[observer] >>> #{raw_data.unpack("H*").first}"
      send_procon(raw_data)
    rescue IO::EAGAINWaitReadable
      # no-op
    end

    5.times do
      begin
        raw_data = non_blocking_read_procon
        output_report_observer.mark_as_receive(raw_data)
        ProconBypassMan.logger.info "[observer] <<< #{raw_data.unpack("H*").first}"
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
    raw_data = gadget.read_nonblock(64)
    return raw_data
  end

  # @raise [IO::EAGAINWaitReadable]
  # @return [String]
  def non_blocking_read_procon
    raw_data = procon.read_nonblock(64)
    return raw_data
  end

  # @return [void]
  def send_procon(raw_data)
    procon.write_nonblock(raw_data)
  end

  # @return [void]
  def send_switch(raw_data)
    gadget.write_nonblock(raw_data)
  end
end
