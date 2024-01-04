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
        ProconBypassMan.logger.info "[pre_bypass] <<< #{raw_data.unpack1("H*")}"

        if(first_data_part = raw_data[0].unpack1("H*"))
          sub_command = raw_data[15..16].unpack1("H*")
          if first_data_part == '21' && sub_command == "5060" # Controller Color
            # new_color_bytes = ['bc 11 42, 75 a9 28, ff ff ff, ff ff ff'.gsub(/[,\s]/, "")].pack('H*') # new color
            new_color_bytes = ['ff 00 00, ff ff ff, ff 00 00, ff 00 00'.gsub(/[,\s]/, '')].pack('H*') # new color
            new_color_bytes = ['bc 11 42, 75 a9 28, ff ff ff, ff ff ff'.gsub(/[,\s]/, '')].pack('H*') # new color

            # 216f81008000911870a54771049010  5060  00 00 0d, 32 32 32, ff ff ff, ff ff ff, ff ff f
            # 216f81008000911870a54771049010  5060  00 00 0d, 32 32 32, ff ff ff, ff ff ff, ff ff f
            # 210781008000f8d77a22c87b0c9010, 5060, 00,00,10, bc 11 42, 75 a9 28, ffffffffffffff00000000000000000000000000000000000000000000000000000000000000
            # 216f81008000911870a54771049010, 5060, 00,00,0d, 32 32 32, ffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000
            # 216f81008000911870a54771049010  5060, 00,00,0d, 323232ffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000

            # 0103000000000000000010506000000d000000000000000000000000000000000000000000000000000000000000000000
            # 216f81008000911870a54771049010506000000d,323232, ff ff ff, ff ff ff ff ffff0000000000000000000000000000000000000000000000000000000000000000
            raw_data[20...(20+(3*4))] = new_color_bytes
            # raw_data.unpack1("H*")
          end
        end

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
