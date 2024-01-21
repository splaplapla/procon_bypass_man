module ProconBypassMan
  module ExternalInput
    class ExternalData
      UNPRESS_BUTTONS = Set.new(ProconBypassMan::Procon::ButtonCollection.available.map { |x| :"un#{x}" })

      # @return [String, NilClass] 16進数表現のデータ
      attr_reader :hex

      # @return [String, NilClass] ログに表示する用
      attr_reader :raw_data

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

        return new(hex: nil, buttons: raw_data.scan(/:\w+:/).map { |x| x.gsub(':', '') }, raw_data: raw_data)
      end

      # @param [String] raw_data
      # @return [Boolean]
      def self.is_json(raw_data)
        raw_data.start_with?('{')
      end

      # @param [String, NilClass] hex
      # @param [Array<String>, NilClass] buttons
      # @param [String, NilClass] raw_data
      def initialize(hex: , buttons: , raw_data: nil)
        @hex = hex
        @buttons = buttons || []
        @raw_data = raw_data
      end

      # @return [String, NilClass]
      def to_binary
        return nil if @hex.nil?
        [@hex].pack('H*')
      end

      # @return [Array<Symbol>]
      def press_buttons
        buttons.select do |button|
          ProconBypassMan::Procon::ButtonCollection::BUTTONS_MAP[button]
        end
      end

      # @return [Array<Symbol>]
      def unpress_buttons
        buttons.select { |button|
          UNPRESS_BUTTONS.include?(button)
        }.map { |b| to_button(b.to_s).to_sym }
      end

      # NOTE: ログに表示する用
      # @return [Array<Symbol>]
      def buttons
        @buttons.map(&:to_sym)
      end

      private

      # @return [String]
      # NOTE: un#{button} って名前をbuttonに変換する
      def to_button(button)
        button.sub(/^un/, '')
      end
    end
  end
end
