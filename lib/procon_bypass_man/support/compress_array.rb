module ProconBypassMan
  class CompressArray
    class CompressibleValue
      # @params [String] prev
      # @params [String] current
      def initialize(prev, current)
        @prev = prev
        @current = current
      end

      # @return [Boolean]
      def compress?
        @prev.include?(@current)
      end

      # @return [String]
      def to_s_with_mark
        if /^(.+) \* (\d+)/ =~ @prev
          value = $1
          count = $2
          return "#{value} * #{count.to_i + 1}"
        end
        if /^(.+)/ =~ @prev
          value = $1
          return "#{value} * 1"
        end
      end
    end

    def initialize(array)
      @array = array
    end

    # @return [Array<String>]
    def compress
      previous_value = nil
      @array.reduce([]) do |acc, item|
        if previous_value.nil?
          acc << item
          previous_value = item
          next acc
        end

        if CompressibleValue.new(previous_value, item).compress?
          registered_value = acc.pop
          acc << CompressibleValue.new(registered_value, item).to_s_with_mark
        else
          acc << item
        end

        previous_value = item
        next acc
      end
    end
  end
end


if $0 == __FILE__
  ProconBypassMan::CompressArray.new([''])
end
