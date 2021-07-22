class ProconBypassMan::Bypass::Simulator
  class Value
    attr_accessor :read_from, :values
    def initialize(values: , read_from: )
      @values = values
      @read_from = read_from
    end
  end

  PROCON_PATH = "/dev/hidraw0"
  PROCON2_PATH = "/dev/hidraw1"

  def initialize
    @stack = []
    # init_devices
  end

  def add(values , read_from: )
    @stack << Value.new(values: values, read_from: read_from)
  end

  def run
    while(item = @stack.pop)
      item.values.each do |value|
        data = nil
        begin
          data = from_device(item).read_nonblock(128)
        rescue IO::EAGAINWaitReadable
          retry
        end
        puts "expected: #{value}, got: #{data.unpack("H*")}"
        to_device(item).write_nonblock(data)
      end
    end
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

  def to_bin(string)
    string.unpack "H*"
  end

  def init_devices
    binding.pry

    case
    when is_available_device?(PROCON_PATH)
      puts("proconのデバイスファイルは#{PROCON_PATH}を使います")
      @procon = File.open(PROCON_PATH, "w+")
      @gadget = File.open('/dev/hidg0', "w+")
    when is_available_device?(PROCON2_PATH)
      puts("proconのデバイスファイルは#{PROCON2_PATH}を使います")
      @procon = File.open(PROCON2_PATH, "w+")
      @gadget = File.open('/dev/hidg0', "w+")
    end
    system('echo > /sys/kernel/config/usb_gadget/procon/UDC')
    system('ls /sys/class/udc > /sys/kernel/config/usb_gadget/procon/UDC')
    sleep 0.5
  end
end
