module ProconBypassMan::DeviceConnection
  class BytesMismatchError < StandardError; end
  class NotFoundProconError < StandardError; end
end

require_relative "device_connection/executor"
require_relative "device_connection/pre_bypass"
require_relative "device_connection/command"
