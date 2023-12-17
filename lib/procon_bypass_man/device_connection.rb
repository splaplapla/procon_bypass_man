module ProconBypassMan::DeviceConnection
  class BytesMismatchError < StandardError; end
  class NotFoundProconError < StandardError; end
  class TimeoutErrorInConditionalRoute < StandardError; end
  class TimeoutError < StandardError; end
  class SetupIncompleteError < StandardError; end
end

require_relative "device_connection/executor"
require_relative "device_connection/pre_bypass"
require_relative "device_connection/command"
require_relative "device_connection/output_report_markerable"
require_relative "device_connection/procon_setting_overrider"
require_relative "device_connection/output_report_generator"
require_relative "device_connection/output_report_sub_command_table"
require_relative "device_connection/spoofing_output_report_watcher"
require_relative "device_connection/output_report_watcher"
