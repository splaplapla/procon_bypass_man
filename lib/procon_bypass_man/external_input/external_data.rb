module ProconBypassMan
  module ExternalInput
    class ExternalData

      attr_accessor :raw_binary, :buttons

      # @raise [ParseError]
      # @return [ExternalData]
      def self.parse!(raw_data)
        json = JSON.parse(raw_data)
        new(raw: json['raw_binary'], buttons: json['buttons'])
      rescue JSON::ParserError
        raise ParseError
      end

      # @param [String, NilClass] raw
      # @param [Array<String>, NilClass] buttons
      def initialize(raw: , buttons: )
        @raw_binary = raw
        @buttons = buttons || []
      end
    end
  end
end
