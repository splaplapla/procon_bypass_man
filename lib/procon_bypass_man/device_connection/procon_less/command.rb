class ProconBypassMan::DeviceConnection::ProconLess::Command
  attr_accessor :gadget

  # @return [void]
  def self.execute
    gadget = self.initialize_gadget
    new(gadget: gadget).execute
  end

  # @return [File] gadget
  def self.initialize_gadget
    ProconBypassMan::UsbDeviceController.init
    ProconBypassMan::UsbDeviceController.reset

    # TODO: ProconBypassMan::DeviceConnection::Executer#init_devicesと同じことを書いているのでこの手続きを切り出したい
    begin
      return File.open('/dev/hidg0', "w+b")
    rescue Errno::ENXIO => e
      # /dev/hidg0 をopenできないときがある
      ProconBypassMan::SendErrorCommand.execute(error: "Errno::ENXIOが起きたのでresetします.\n #{e.full_message}", stdout: false)
      ProconBypassMan::UsbDeviceController.reset
      retry
    end
  end

  # @param [File] gadget
  def initialize(gadget: )
    @gadget = gadget
  end

  # @return [void]
  # @raise [ProconBypassMan::SafeTimeout::Timeout]
  def execute
    pre_bypass_first
    pre_bypass
  end

  private

  def pre_bypass_first
    output_report_watcher = OutputReportWatcher.new([
      /^0000/,
      /^0000/,
      /^8005/,
      /^0000/,
      /^8001/,
      /^8002/,
      /^01000000000000000000033/,
      /^8004/,
    ])
    negotiator = ReportNegotiator.new(gadget: gadget, output_report_watcher: output_report_watcher)
    negotiator.execute
  end

  def pre_bypass
    output_report_watcher = OutputReportWatcher.new([
      "01-04",
      "02-",
      "04-00",
      "08-00",
      "10-00",
      "10-50",
      "10-80",
      "10-98",
      "10-10",
      "30-",
      "40-",
      "48-",
    ])
    negotiator = ReportNegotiator.new(gadget: gadget, output_report_watcher: output_report_watcher)
    negotiator.execute
  end
end
