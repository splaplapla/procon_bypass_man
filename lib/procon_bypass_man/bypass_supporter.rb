class ProconBypassMan::BypassSupporter
  class Timer
    class Timeout < StandardError; end

    # 5秒後がタイムアウト
    def initialize(timeout: Time.now + 5)
      @timeout = timeout
    end

    def throw_if_timeout!
      raise Timeout if @timeout < Time.now
    end
  end

  class Value
    attr_accessor :read_from, :values
    def initialize(values: , read_from: )
      @values = values
      @read_from = read_from
    end
  end

  PROCON_PATH = "/dev/hidraw0"
  PROCON2_PATH = "/dev/hidraw1"

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

  def initialize(throw_error_if_timeout: false, enable_at_exit: true)
    @stack = []
    @initialized_devices = false
    @throw_error_if_timeout = throw_error_if_timeout
    @enable_at_exit = enable_at_exit
  end

  def add(values, read_from: )
    @stack << Value.new(values: values, read_from: read_from)
  end

  def drain_all
    unless @initialized_devices
      init_devices
    end

    while(item = @stack.pop)
      item.values.each do |value|
        data = nil
        timer = Timer.new
        begin
          timer.throw_if_timeout!
          data = from_device(item).read_nonblock(128)
        rescue IO::EAGAINWaitReadable
          retry
        end

        if value == data.unpack("H*")
          puts "OK(expected: #{value}, got: #{data.unpack("H*")})"
        else
          puts "NG(expected: #{value}, got: #{data.unpack("H*")})"
        end
        to_device(item).write_nonblock(data)
      end
    end
  rescue Timer::Timeout
    puts "timeoutになりました"
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

    timer = Timer.new
    data = nil
    begin
      timer.throw_if_timeout!
      switch.write_nonblock(data)
    rescue IO::EAGAINWaitReadable
      retry
    rescue Timer::Timeout
      puts "writeでtimeoutになりました"
      raise
    end
    return(data.unpack("H*")) if only_write

    timer = Timer.new
    begin
      timer.throw_if_timeout!
      data = switch.read_nonblock(128)
      puts " <<< #{data.unpack("H*")})"
    rescue IO::EAGAINWaitReadable
      retry
    rescue Timer::Timeout
      puts "readでtimeoutになりました"
      raise
    end
  rescue Timer::Timeout
    raise if @throw_error_if_timeout
  end

  def write_procon(data, only_write: false)
    if data.encoding.name == "UTF-8"
      data = [data].pack("H*")
    end
    unless @initialized_devices
      init_devices
    end

    timer = Timer.new
    begin
      timer.throw_if_timeout!
      procon.write_nonblock(data)
    rescue IO::EAGAINWaitReadable
      retry
    rescue Timer::Timeout
      puts "writeでtimeoutになりました"
      raise
    end
    return(data.unpack("H*")) if only_write

    timer = Timer.new
    begin
      timer.throw_if_timeout!
      data = procon.read_nonblock(128)
      puts " <<< #{data.unpack("H*")})"
    rescue IO::EAGAINWaitReadable
      retry
    rescue Timer::Timeout
      puts "readでtimeoutになりました"
      raise
    end
  rescue Timer::Timeout
    raise if @throw_error_if_timeout
  end

  def read_procon(only_read: false)
    unless @initialized_devices
      init_devices
    end

    data = nil
    timer = Timer.new
    begin
      timer.throw_if_timeout!
      data = procon.read_nonblock(128)
      puts " <<< #{data.unpack("H*")})"
    rescue IO::EAGAINWaitReadable
      retry
    rescue Timer::Timeout
      puts "readでtimeoutになりました"
      raise
    end
    return(data.unpack("H*")) if only_read

    timer = Timer.new
    begin
      timer.throw_if_timeout!
      switch.write_nonblock(data)
    rescue IO::EAGAINWaitReadable
      retry
    rescue Timer::Timeout
      puts "writeでtimeoutになりました"
      raise
    end
  rescue Timer::Timeout
    raise if @throw_error_if_timeout
  end

  def read_switch(only_read: false)
    unless @initialized_devices
      init_devices
    end

    data = nil
    timer = Timer.new
    begin
      timer.throw_if_timeout!
      data = switch.read_nonblock(128)
      puts " >>> #{data.unpack("H*")})"
    rescue IO::EAGAINWaitReadable
      retry
    rescue Timer::Timeout
      puts "readでtimeoutになりました"
      raise
    end
    return(data.unpack("H*")) if only_read

    timer = Timer.new
    begin
      timer.throw_if_timeout!
      procon.write_nonblock(data)
    rescue IO::EAGAINWaitReadable
      retry
    rescue Timer::Timeout
      puts "writeでtimeoutになりました"
      raise
    end
  rescue Timer::Timeout
    raise if @throw_error_if_timeout
  end

  def from_device(item)
    case item.read_from
    when :switch
      self.public_send(:switch)
    else
      raise
    end
  end

  # fromの対になる
  def to_device(item)
    case item.read_from
    when :switch
      self.public_send(:procon)
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
      puts("proconのデバイスファイルは#{PROCON_PATH}を使います")
      @procon = File.open(PROCON_PATH, "w+")
      @gadget = File.open('/dev/hidg0', "w+")
    when is_available_device?(PROCON2_PATH)
      puts("proconのデバイスファイルは#{PROCON2_PATH}を使います")
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
    puts "Errno::ENXIO (No such device or address @ rb_sysopen - /dev/hidg0)が起きました。resetします"
    puts e
    system('echo > /sys/kernel/config/usb_gadget/procon/UDC')
    system('ls /sys/class/udc > /sys/kernel/config/usb_gadget/procon/UDC')
    sleep 2
    retry
  end
end
