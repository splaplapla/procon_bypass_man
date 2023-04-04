module ProconBypassMan
  module ExternalInput
    class ExternalData
      UNPRESS_BUTTONS = Set.new(ProconBypassMan::Procon::ButtonCollection.available.map { |x| "un#{x}".to_sym })

      attr_accessor :hex

      # @raise [ParseError]
      # @return [ExternalData] JSON か カンマ区切りのbuttons
      def self.parse!(raw_data)
        raise ParseError unless raw_data.ascii_only?

        if is_json(raw_data)
          begin
            json = JSON.parse(raw_data)
            return new(hex: json['hex'], buttons: json['buttons'])
          rescue JSON::ParserError
            raise ParseError
          end
        end

        # NOTE: カンマを含めた `a,` を1セットとして扱う
        return new(hex: nil, buttons: raw_data.scan(/\w+,/).map { |x| x.gsub(',', '') })
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

      # @return [Array<Symbol>]
      def buttons
        @buttons.map(&:to_sym)
      end

      # @return [Array<Symbol>]
      def press_buttons
        buttons.select do |button|
          ProconBypassMan::Procon::ButtonCollection::BUTTONS_MAP[button]
        end
      end

      # @return [Array<Symbol>]
      def unpress_buttons
        buttons.select do |button|
          UNPRESS_BUTTONS.include?(button)
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
