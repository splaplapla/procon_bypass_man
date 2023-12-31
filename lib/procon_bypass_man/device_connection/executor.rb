require "timeout"

class ProconBypassMan::DeviceConnection::Executer
  class Value
    attr_accessor :read_from, :values, :call_block_if_receive, :block

    def initialize(values: , read_from: , call_block_if_receive: false, &block)
      @values = values
      @read_from = read_from
      @call_block_if_receive = call_block_if_receive
      @block = block
    end
  end

  def self.new_with_default_args
    new(throw_error_if_timeout: true)
  end

  def self.execute!
    s = new_with_default_args
    s.add(expected_to_receive: [
      ["0000"],
      ["0000"],
      ["8005"],
      ["0000"],
    ], read_from: :switch)
    # 1. Sends current connection status, and if the Joy-Con are connected,
    s.add(expected_to_receive: [["8001"]], read_from: :switch)
    s.add(expected_to_receive: [/^8101/], read_from: :procon) # <<< 81010003176d96e7a5480000000, macaddressとコントローラー番号を返す
    # 2. Sends handshaking packets over UART to the Joy-Con or Pro Controller Broadcom chip. This command can only be called once per session.
    s.add(expected_to_receive: [["8002"]], read_from: :switch)
    s.add(expected_to_receive: [/^8102/], read_from: :procon)
    # 3
    s.add(expected_to_receive: [/^0100/], read_from: :switch)
    s.add(expected_to_receive: [/^21/], read_from: :procon, call_block_if_receive: /^8101/) do |this|
      begin
        ProconBypassMan.logger.info "(start special route)"
        this.blocking_read_with_timeout_from_procon # <<< 810100032dbd42e9b698000
        this.write_to_procon("8002")
        this.blocking_read_with_timeout_from_procon # <<< 8102
        this.write_to_procon("01000000000000000000033000000000000000000000000000000000000000000000000000000000000000000000000000")
        this.blocking_read_with_timeout_from_procon # <<< 21
      rescue ProconBypassMan::SafeTimeout::Timeout, Timeout::Error
        raise ProconBypassMan::DeviceConnection::TimeoutErrorInConditionalRoute
      end
    end

    # 4. Forces the Joy-Con or Pro Controller to only talk over USB HID without any timeouts. This is required for the Pro Controller to not time out and revert to Bluetooth.
    s.add(expected_to_receive: [["8004"]], read_from: :switch)
    s.drain_all
    return [s.switch, s.procon]
  end

  def initialize(throw_error_if_timeout: false, throw_error_if_mismatch: false)
    @queue = []
    @initialized_devices = false
    @throw_error_if_timeout = throw_error_if_timeout
    @throw_error_if_mismatch = throw_error_if_mismatch
  end

  def add(expected_to_receive: , read_from: , call_block_if_receive: nil, &block)
    values = expected_to_receive
    @queue << Value.new(values: values, read_from: read_from, call_block_if_receive: call_block_if_receive, &block)
  end

  def drain_all
    debug_log_buffer = []
    unless @initialized_devices
      init_devices
    end

    while(item = @queue.shift)
      item.values.each do |value|
        raw_data = nil
        timer = ProconBypassMan::SafeTimeout.new

        begin
          timer.throw_if_timeout!
          raw_data = from_device(item).read_nonblock(64)
          debug_log_buffer << "read_from(#{item.read_from}): #{raw_data.unpack("H*")}"
        rescue IO::EAGAINWaitReadable
          # debug_log_buffer << "read_from(#{item.read_from}): IO::EAGAINWaitReadable"
          retry
        end

        if item.call_block_if_receive
          ProconBypassMan.logger.info "call block if receive: #{item.call_block_if_receive}, actual: #{raw_data.unpack("H*")} from: #{item.read_from}"
          if item.call_block_if_receive =~ raw_data.unpack("H*").first
            raw_data = item.block.call(self)
          end
        end

        result =
          case value
          when String, Array
            value == raw_data.unpack("H*")
          when Regexp
            value =~ raw_data.unpack("H*").first
          else
            raise "#{value}は知りません"
          end

        if result
          ProconBypassMan.logger.info "OK(expected: #{value}, got: #{raw_data.unpack("H*")}) from: #{item.read_from}"
          debug_log_buffer << "OK(expected: #{value}, got: #{raw_data.unpack("H*")}) from: #{item.read_from}"
        else
          ProconBypassMan.logger.info "NG(expected: #{value}, got: #{raw_data.unpack("H*")}) from: #{item.read_from}"
          debug_log_buffer << "NG(expected: #{value}, got: #{raw_data.unpack("H*")}) from: #{item.read_from}"
          raise ProconBypassMan::DeviceConnection::BytesMismatchError.new(debug_log_buffer) if @throw_error_if_mismatch
        end
        to_device(item).write_nonblock(raw_data)
      end
    end
  rescue ProconBypassMan::SafeTimeout::Timeout, Timeout::Error => e
    ProconBypassMan.logger.error "timeoutになりました(#{e.message})"
    procon.write_nonblock(['8006'].pack("H*")) # 再実行時のケーブルの再接続を不要にするワークアラウンド. リセットしているらしい
    compressed_buffer_text = ProconBypassMan::CompressArray.new(debug_log_buffer).compress.join("\n")
    ProconBypassMan::SendErrorCommand.execute(error: compressed_buffer_text, stdout: false)
    raise ProconBypassMan::SafeTimeout::Timeout if @throw_error_if_timeout
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

  GADGET_PATH = '/dev/hidg0'
  def init_devices
    unless SudoNeedPasswordChecker.execute!
      raise ProconBypassMan::DeviceConnection::SetupIncompleteError
    end

    if @initialized_devices
      return
    end

    ProconBypassMan::UsbDeviceController.init
    ProconBypassMan::UsbDeviceController.reset

    if path = ProconBypassMan::DeviceProconFinder.find
      ShellRunner.execute("sudo chmod 777 #{path}")
      @procon = File.open(path, "w+b")
      ProconBypassMan.logger.info "proconのデバイスファイルは#{path}を使います"
    else
      raise(ProconBypassMan::DeviceConnection::NotFoundProconError)
    end

    begin
      ShellRunner.execute("sudo chmod 777 #{GADGET_PATH}")
      @gadget = File.open(GADGET_PATH, "w+b")
    rescue Errno::ENXIO => e
      # /dev/hidg0 をopenできないときがある
      ProconBypassMan::SendErrorCommand.execute(error: "Errno::ENXIOが起きたのでresetします.\n #{e.full_message}", stdout: false)
      ProconBypassMan::UsbDeviceController.reset
      retry
    end

    @initialized_devices = true
  end

  def blocking_read_with_timeout_from_procon
    Timeout.timeout(4) do
      raw_data = procon.read(64)
      ProconBypassMan.logger.info "<<< #{raw_data.unpack("H*").first}"
      return raw_data
    end
  end

  def write_to_procon(data)
    ProconBypassMan.logger.info ">>> #{data}"
    procon.write_nonblock([data].pack("H*"))
  end
end
