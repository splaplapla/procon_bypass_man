class ProconBypassMan::DeviceConnector
  class BytesMismatchError < StandardError; end

  class Value
    attr_accessor :read_from, :values
    def initialize(values: , read_from: )
      @values = values
      @read_from = read_from
    end
  end

  PROCON_PATH = "/dev/hidraw0"
  PROCON2_PATH = "/dev/hidraw1"

  # 画面で再接続ができたが状況は変わらない
  def self.reset_connection!
    s = new
    s.add([
      ["0000"],
      ["0000"],
      ["8005"],
      ["0000"],
      ["8001"],
    ], read_from: :switch)
    s.drain_all
    s.read_procon
    s.write_switch("213c910080005db7723d48720a800300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
    sleep(10) # いらないかも
    s
  end

  def self.connect
    s = new(throw_error_if_timeout: true, enable_at_exit: false)
    s.add([
      ["0000"],
      ["0000"],
      ["8005"],
      ["0010"],
    ], read_from: :switch)
    # 1. Sends current connection status, and if the Joy-Con are connected,
    s.add([["8001"]], read_from: :switch)
    s.add([/^8101/], read_from: :procon) # <<< 81010003176d96e7a5480000000, macaddressとコントローラー番号を返す
    # 2. Sends handshaking packets over UART to the Joy-Con or Pro Controller Broadcom chip. This command can only be called once per session.
    s.add([["8002"]], read_from: :switch)
    s.add([/^8102/], read_from: :procon)
    # 3
    s.add([/^0100/], read_from: :switch)
    s.add([/^21/], read_from: :procon)
    # 4. Forces the Joy-Con or Pro Controller to only talk over USB HID without any timeouts. This is required for the Pro Controller to not time out and revert to Bluetooth.
    s.add([["8004"]], read_from: :switch)
    s.drain_all
    return [s.switch, s.procon]
  end

  def initialize(throw_error_if_timeout: false, throw_error_if_mismatch: false , enable_at_exit: true)
    @stack = []
    @initialized_devices = false
    @throw_error_if_timeout = throw_error_if_timeout
    @throw_error_if_mismatch = throw_error_if_mismatch
    @enable_at_exit = enable_at_exit
  end

  def add(values, read_from: )
    @stack << Value.new(values: values, read_from: read_from)
  end

  def drain_all
    unless @initialized_devices
      init_devices
    end

    while(item = @stack.shift)
      item.values.each do |value|
        data = nil
        timer = ProconBypassMan::Timer.new
        begin
          timer.throw_if_timeout!
          data = from_device(item).read_nonblock(128)
        rescue IO::EAGAINWaitReadable
          retry
        end

        result =
          case value
          when String, Array
            value == data.unpack("H*")
          when Regexp
            value =~ data.unpack("H*").first
          else
            raise "#{value}は知りません"
          end
        if result
          ProconBypassMan.logger.info "OK(expected: #{value}, got: #{data.unpack("H*")})"
        else
          ProconBypassMan.logger.info "NG(expected: #{value}, got: #{data.unpack("H*")})"
          raise BytesMismatchError if @throw_error_if_mismatch
        end
        to_device(item).write_nonblock(data)
      end
    end
  rescue ProconBypassMan::Timer::Timeout
    ProconBypassMan.logger.error "timeoutになりました"
    raise if @throw_error_if_timeout
  end

  # switchに任意の命令を入力して、switchから読み取る
  def write_switch(data, only_write: false)
    if data.encoding.name == "UTF-8"
      data = [data].pack("H*")
    end
    unless @initialized_devices
      init_devices
    end

    timer = ProconBypassMan::Timer.new
    data = nil
    begin
      timer.throw_if_timeout!
      switch.write_nonblock(data)
    rescue IO::EAGAINWaitReadable
      retry
    rescue ProconBypassMan::Timer::Timeout
      ProconBypassMan.logger.error "writeでtimeoutになりました"
      raise
    end
    return(data.unpack("H*")) if only_write

    timer = ProconBypassMan::Timer.new
    begin
      timer.throw_if_timeout!
      data = switch.read_nonblock(128)
      ProconBypassMan.logger.debug { " >>> #{data.unpack("H*")})" }
    rescue IO::EAGAINWaitReadable
      retry
    rescue ProconBypassMan::Timer::Timeout
      ProconBypassMan.logger.error "readでtimeoutになりました"
      raise
    end
  rescue ProconBypassMan::Timer::Timeout
    raise if @throw_error_if_timeout
  end

  def write_procon(data, only_write: false)
    if data.encoding.name == "UTF-8"
      data = [data].pack("H*")
    end
    unless @initialized_devices
      init_devices
    end

    timer = ProconBypassMan::Timer.new
    begin
      timer.throw_if_timeout!
      procon.write_nonblock(data)
    rescue IO::EAGAINWaitReadable
      retry
    rescue ProconBypassMan::Timer::Timeout
      ProconBypassMan.logger.error "writeでtimeoutになりました"
      raise
    end
    return(data.unpack("H*")) if only_write

    timer = ProconBypassMan::Timer.new
    begin
      timer.throw_if_timeout!
      data = procon.read_nonblock(128)
      ProconBypassMan.logger.error " <<< #{data.unpack("H*")})"
    rescue IO::EAGAINWaitReadable
      retry
    rescue ProconBypassMan::Timer::Timeout
      ProconBypassMan.logger.error "readでtimeoutになりました"
      raise
    end
  rescue ProconBypassMan::Timer::Timeout
    raise if @throw_error_if_timeout
  end

  def read_procon(only_read: false)
    unless @initialized_devices
      init_devices
    end

    data = nil
    timer = ProconBypassMan::Timer.new
    begin
      timer.throw_if_timeout!
      data = procon.read_nonblock(128)
      ProconBypassMan.logger.debug { " <<< #{data.unpack("H*")})" }
    rescue IO::EAGAINWaitReadable
      retry
    rescue ProconBypassMan::Timer::Timeout
      ProconBypassMan.logger.error "readでtimeoutになりました"
      raise
    end
    return(data.unpack("H*")) if only_read

    timer = ProconBypassMan::Timer.new
    begin
      timer.throw_if_timeout!
      switch.write_nonblock(data)
    rescue IO::EAGAINWaitReadable
      retry
    rescue ProconBypassMan::Timer::Timeout
      ProconBypassMan.logger.error "writeでtimeoutになりました"
      raise
    end
  rescue ProconBypassMan::Timer::Timeout
    raise if @throw_error_if_timeout
  end

  def read_switch(only_read: false)
    unless @initialized_devices
      init_devices
    end

    data = nil
    timer = ProconBypassMan::Timer.new
    begin
      timer.throw_if_timeout!
      data = switch.read_nonblock(128)
      ProconBypassMan.logger.debug { " >>> #{data.unpack("H*")})" }
    rescue IO::EAGAINWaitReadable
      retry
    rescue ProconBypassMan::Timer::Timeout
      ProconBypassMan.logger.error "readでtimeoutになりました"
      raise
    end
    return(data.unpack("H*")) if only_read

    timer = ProconBypassMan::Timer.new
    begin
      timer.throw_if_timeout!
      procon.write_nonblock(data)
    rescue IO::EAGAINWaitReadable
      retry
    rescue ProconBypassMan::Timer::Timeout
      ProconBypassMan.logger.error "writeでtimeoutになりました"
      raise
    end
  rescue ProconBypassMan::Timer::Timeout
    raise if @throw_error_if_timeout
  end

  def from_device(item)
    case item.read_from
    when :switch
      switch
    when :procon
      procon
    else
      raise
    end
  end

  # fromの対になる
  def to_device(item)
    case item.read_from
    when :switch
      procon
    when :procon
      switch
    else
      raise
    end
  end

  def switch
    @gadget
  end

  def procon
    @procon
  end

  def is_available_device?(path)
    return false if !File.exist?(path)

    system('echo > /sys/kernel/config/usb_gadget/procon/UDC')
    system('ls /sys/class/udc > /sys/kernel/config/usb_gadget/procon/UDC')
    sleep 0.5

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

  def to_bin(string)
    string.unpack "H*"
  end

  def init_devices
    if @initialized_devices
      return
    end

    case
    when is_available_device?(PROCON_PATH)
      ProconBypassMan.logger.info "proconのデバイスファイルは#{PROCON_PATH}を使います"
      @procon = File.open(PROCON_PATH, "w+")
      @gadget = File.open('/dev/hidg0', "w+")
    when is_available_device?(PROCON2_PATH)
      ProconBypassMan.logger.info "proconのデバイスファイルは#{PROCON2_PATH}を使います"
      @procon = File.open(PROCON2_PATH, "w+")
      @gadget = File.open('/dev/hidg0', "w+")
    else
      raise "/dev/hidraw0, /dev/hidraw1の両方見つかりませんでした"
    end
    system('echo > /sys/kernel/config/usb_gadget/procon/UDC')
    system('ls /sys/class/udc > /sys/kernel/config/usb_gadget/procon/UDC')
    sleep 0.5

    @initialized_devices = true

    if @enable_at_exit
      at_exit do
        @procon&.close
        @gadget&.close
      end
    end
  rescue Errno::ENXIO => e
    # /dev/hidg0 をopenできないときがある
    ProconBypassMan.logger.error "Errno::ENXIO (No such device or address @ rb_sysopen - /dev/hidg0)が起きました。resetします"
    ProconBypassMan.logger.error e
    system('echo > /sys/kernel/config/usb_gadget/procon/UDC')
    system('ls /sys/class/udc > /sys/kernel/config/usb_gadget/procon/UDC')
    sleep 2
    retry
  end
end
