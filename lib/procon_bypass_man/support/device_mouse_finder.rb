class ProconBypassMan::DeviceMouseFinder
  class USBDevice < Struct.new(:display_name, :event_no)
    # TODO bInterfaceProtocolの値を見てmouseかを判断したい
    def mouse?
      !!(display_name =~ /mouse/i)
    end

    def keyboard?
      !!(display_name =~ /keyboard/i)
    end

    def event_device_path
     "/dev/input/#{event_no}"
    end
  end

  class Parser
    def self.parse(shell_output)
      instance = new
      instance.set_usb_devices_from(shell_output)
      instance
    end

    def set_usb_devices_from(shell_output)
      @usb_devices =
        shell_output.split(/\n\n/).map do |text|
          display_name =  /N: Name="(.+?)"$/ =~ text && $1
          event_no = /H: Handlers=.*?(event\d).*?$/ =~ text && $1
          USBDevice.new(display_name, event_no)
        end
    end

    def usb_devices
      @usb_devices ||= []
    end
  end

  def self.find
    new.find
  end

  # @return [String, NilClass]
  def find
    find_path
  end

  private

  def find_path
    Parser.parse(shell_output).usb_devices.detect(&:mouse?)&.event_device_path
  end

  def shell_output
    `bash -c '#{shell}'`
  end

  def shell
    'cat /proc/bus/input/devices'
  end
end
