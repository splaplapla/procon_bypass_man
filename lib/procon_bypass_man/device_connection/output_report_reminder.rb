class ProconBypassMan::DeviceConnection::OutputReportReminder
  class HIDSubCommandRequest
    def initialize(counter: , sub_command: , arg: )
      @counter = counter.to_s(16).rjust(2, "0")
      @sub_command = sub_command
      @arg = arg
    end

    def to_byte
      ["01", @counter, "00" * 8, @sub_command, @arg].join
    end
  end

  class HIDSubCommandResponse
    attr_accessor :sub_command

    def self.parse(data)
      if sub_command = data[28..29]
        new(sub_command: sub_command)
      else
        raise "could not parse"
      end
    end

    def initialize(sub_command: )
      @sub_command = sub_command
    end

    def sub_command_name
      SUB_COMMANDS_ID_TABLE[@sub_command]
    end
  end

  class CommandReceivedStatus
    def initialize
      @status = :init
    end

    def sent!(step: )
      @status = :sent
      @step = step
    end

    def received_ack!
      @status = :received_ack
    end

    def received_ack?
      @status == :received_ack
    end

    def init?
      @status == :init
    end

    def step
      @step
    end
  end

  module Commander
    def enable_player_light
      HIDSubCommandRequest.new(counter: @counter, sub_command: "30", arg: "01").to_byte
    end

    def disable_player_light
      HIDSubCommandRequest.new(counter: @counter, sub_command: "30", arg: "00").to_byte
    end

    def enable_home_button_light
      HIDSubCommandRequest.new(counter: @counter, sub_command: "38", arg: "01").to_byte
    end

    def disable_home_button_light
      HIDSubCommandRequest.new(counter: @counter, sub_command: "38", arg: "00").to_byte
    end

    def disable_vibration
      HIDSubCommandRequest.new(counter: @counter, sub_command: "48", arg: "00").to_byte
    end
  end

  include Commander

  attr_accessor :counter
  attr_accessor :player_light, :home_button_light

  SUB_COMMANDS = [
    # "18", # SPI read. not support
    # "12",
    ["30", "01"], # player_light
    ["38", "01"], # home_button_light
  ]

  SUB_COMMANDS_ON_START = [
    # :enable_player_light,
    :disable_vibration,
    :enable_home_button_light,
  ]

  SUB_COMMANDS_ON_END = [
    :disable_home_button_light,
  ]

  SUB_COMMANDS_NAME_TABLE = {
    enable_player_light: :player_light,
    disable_player_light: :player_light,
    enable_home_button_light: :home_button_light,
    disable_home_button_light: :home_button_light,
  }

  SUB_COMMANDS_ID_TABLE = {
    "30" => :player_light,
    "38" => :home_button_light,
  }

  def initialize
    @counter = 0
    @sub_command_received_status = CommandReceivedStatus.new
  end

  def mark_as_send(step: )
    name = SUB_COMMANDS_NAME_TABLE[step]
    @sub_command_received_status.sent!(step: step)
  end

  def byte_of(step: )
    out = public_send(step)
    increment_counter
    return out
  end

  def unreceived_byte
    raise "使い方が違います" unless has_unreceived_command?
    byte_of(step: @sub_command_received_status.step)
  end

  def has_unreceived_command?
    return false if @sub_command_received_status.init?
    not @sub_command_received_status.received_ack?
  end

  def receive(raw_data: )
    data = raw_data.unpack("H*").first
    case data
    when /^21/
      response = HIDSubCommandResponse.parse(data)
      if SUB_COMMANDS_NAME_TABLE[@sub_command_received_status.step] == response.sub_command_name
        @sub_command_received_status.received_ack!
      else
        false
      end
    end
  end

  def received?(step: )
    name = SUB_COMMANDS_NAME_TABLE[step]
    @sub_command_received_status.received_ack?
  end

  private

  def increment_counter
    @counter = @counter + 1
    if @counter >= 256
      @counter = 0
    else
      @counter
    end
  end
end
end
