class ProconBypassMan::DeviceProconFinder
  HID_NAME = "Nintendo Co., Ltd. Pro Controller"

  THIRD_PARTY_DEVICE_PATH = "/dev/input/js0"

  def self.find
    new.find
  end

  # @return [String, NilClass]
  def find
    if(procon_path = find_procon_path)
      return procon_path
    end

    if(third_party_device_path = find_third_party_device_path)
      return third_party_device_path
    end
  end

  private

  # @return [String , NilClass]
  def find_third_party_device_path
    if File.exists?(THIRD_PARTY_DEVICE_PATH)
      return THIRD_PARTY_DEVICE_PATH
    end
  end

  # @return [String , NilClass]
  def find_procon_path
    if(line = device_from_shell) && (hidraw_name = line.match(/(hidraw\d+)\s+/)[1])
      "/dev/#{hidraw_name}"
    end
  end

  # @return [String , NilClass]
  def device_from_shell
    shell_output.split("\n").detect { |o| o.include?(HID_NAME) }
  end

  # @return [String]
  def shell_output
    `bash -c '#{get_list_shell}'`
  end

  def get_list_shell
    <<~SHELL
      FILES=/dev/hidraw*
      for f in $FILES
      do
        FILE=${f##*/}
        DEVICE="$(cat /sys/class/hidraw/${FILE}/device/uevent | grep HID_NAME | cut -d '=' -f2)"
        printf "%s   %s\n" $FILE "$DEVICE"
      done
    SHELL
  end
end
