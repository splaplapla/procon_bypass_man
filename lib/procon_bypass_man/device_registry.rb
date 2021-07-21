class ProconBypassMan::DeviceRegistry
  PROCON_PATH = "/dev/hidraw0"
  PROCON2_PATH = "/dev/hidraw1"

  def gadget
    @gadget
  end

  def procon
    @procon
  end

  def initialize
    init_devices
  end

  # @return [void]
  def init_devices
    puts "デバイスの初期化をします"
    ProconBypassMan.logger.info("デバイスの初期化をします")
    loop do
      case
      when is_available_device?(PROCON_PATH)
        ProconBypassMan.logger.info("proconのデバイスファイルは#{PROCON_PATH}を使います")
        system('echo > /sys/kernel/config/usb_gadget/procon/UDC')
        system('ls /sys/class/udc > /sys/kernel/config/usb_gadget/procon/UDC')
        sleep 0.5
        @gadget = File.open('/dev/hidg0', "w+")
        @procon = File.open(PROCON_PATH, "w+")
        break
      when is_available_device?(PROCON2_PATH)
        ProconBypassMan.logger.info("proconのデバイスファイルは#{PROCON2_PATH}を使います")
        system('echo > /sys/kernel/config/usb_gadget/procon/UDC')
        system('ls /sys/class/udc > /sys/kernel/config/usb_gadget/procon/UDC')
        sleep 0.5
        @gadget = File.open('/dev/hidg0', "w+")
        @procon = File.open(PROCON2_PATH, "w+")
        break
      else
        puts "プロコンをラズベイに挿してください"
        ProconBypassMan.logger.info("プロコンをラズベイに挿してください")
        sleep(1)
      end
    end
    puts "デバイスの初期化が終わりました"
    ProconBypassMan.logger.info("デバイスの初期化が終わりました")
  end

  private

  def is_available_device?(path)
    return false if !File.exist?(PROCON_PATH)
    file = File.open(path, "w+")
    begin
      file.read_nonblock(128)
    rescue EOFError
      file.close
      return false
    rescue IO::EAGAINWaitReadable
      file.close
      return true
    end
  end
end
