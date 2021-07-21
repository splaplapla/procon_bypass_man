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
      when File.exist?(PROCON_PATH)
        system('echo > /sys/kernel/config/usb_gadget/procon/UDC')
        system('ls /sys/class/udc > /sys/kernel/config/usb_gadget/procon/UDC')
        sleep 2
        @gadget = File.open('/dev/hidg0', "w+")
        @procon = File.open(PROCON_PATH, "w+")
        break
      when File.exist?(PROCON2_PATH)
        system('echo > /sys/kernel/config/usb_gadget/procon/UDC')
        system('ls /sys/class/udc > /sys/kernel/config/usb_gadget/procon/UDC')
        sleep 2
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
end
