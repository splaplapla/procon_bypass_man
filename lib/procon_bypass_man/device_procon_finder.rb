class ProconBypassMan::DeviceProconFinder
  HID_NAME = "Nintendo Co., Ltd. Pro Controller"

  def self.find
    new.find
  end

  # @return [String, NilClass]
  def find
    find_device_path
  end

  private

  # @return [String , NilClass]
  def find_device_path
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
    file = Tempfile.new
    file.write(get_list_shell)
    `bash #{file.path}` # bash依存なshellなので
  ensure
    file&.close
  end

  def get_list_shell
    <<~SHELL
      #!/bin/bash

      FILES=/dev/hidraw*
      for f in $FILES
      do
        FILE=${f##*/}
        DEVICE="$(cat /sys/class/hidraw/${FILE}/device/uevent | grep HID_NAME | cut -d '=' -f2)"
        printf "%s   %s\n" $FILE "$DEVICE"
      done
    SHELL
  end

  # これいる？
  def is_available_device?(path)
    return false if !File.exist?(path)

    system('echo > /sys/kernel/config/usb_gadget/procon/UDC')
    system('ls /sys/class/udc > /sys/kernel/config/usb_gadget/procon/UDC')
    sleep 0.5

    file = File.open(path, "w+")
    begin
      file.read_nonblock(64)
    rescue EOFError
      file.close
      return false
    rescue IO::EAGAINWaitReadable
      file.close
      return true
    end
  end
end
