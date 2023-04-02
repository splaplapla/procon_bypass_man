module ProconBypassMan
  module ExternalInput
    class ExternalData

      attr_accessor :hex

      # @raise [ParseError]
      # @return [ExternalData] JSON か カンマ区切りのbuttons
      def self.parse!(raw_data)
        if is_json(raw_data)
          begin
            json = JSON.parse(raw_data)
            return new(hex: json['hex'], buttons: json['buttons'])
          rescue JSON::ParserError
            raise ParseError
          end
        end

        return new(hex: nil, buttons: raw_data.split(','))
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

      # @param [String] raw_data
      # @return [Boolean]
      def self.is_json(raw_data)
        raw_data.start_with?('{')
      end
    end
  end
end
