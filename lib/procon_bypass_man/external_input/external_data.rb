module ProconBypassMan
  module ExternalInput
    class ExternalData

      attr_accessor :hex, :buttons

      # @raise [ParseError]
      # @return [ExternalData]
      def self.parse!(raw_data)
        json = JSON.parse(raw_data)
        new(hex: json['hex'], buttons: json['buttons'])
      rescue JSON::ParserError
        raise ParseError
      end

      # @param [String, NilClass] hex
      # @param [Array<String>, NilClass] buttons
      def initialize(hex: , buttons: )
        @hex = hex
        @buttons = buttons || []
      end
    end
  end
end
