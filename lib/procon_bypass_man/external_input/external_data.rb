module ProconBypassMan
  module ExternalInput
    class ExternalData

      attr_accessor :hex

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

      # @return [String, NilClass]
      def to_binary
        return nil if @hex.nil?
        [@hex].pack('H*')
      end

      # @return [Array<String>]
      def buttons
        @buttons.map(&:to_sym).each do |button|
          ProconBypassMan::Procon::ButtonCollection::BUTTONS_MAP[button] or ProconBypassMan.logger.error("[ExternalInput] #{button}は定義にないボタンです")
        end
      end
    end
  end
end
