module ProconBypassMan
  module Domains
    module Binary; end
  end
end

require_relative "domains/binary/base"
require_relative "domains/binary/has_mutable_binary"
require_relative "domains/binary/has_immutable_binary"
require_relative "domains/binary/inbound_procon_binary"
require_relative "domains/binary/processing_procon_binary"
