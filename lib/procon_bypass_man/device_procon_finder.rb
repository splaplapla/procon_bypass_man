class ProconBypassMan::DeviceProconFinder
  def self.find
    new.find
  end

  def initialize
  end

  # @return [File, NilClass]
  def find
  end

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
