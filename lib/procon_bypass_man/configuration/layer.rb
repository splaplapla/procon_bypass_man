module ProconBypassMan
  class Configuration
    class Layer
      attr_accessor :mode, :flips, :macros, :remaps

      def initialize(mode: :manual, &block)
        self.mode = mode
        self.flips = {}
        self.macros = {}
        self.remaps = {}
        instance_eval(&block) if block_given?
      end

      # @param [Symbol] button
      def flip(button, if_pressed: false, force_neutral: nil, flip_interval: nil)
        case if_pressed
        when TrueClass
          if_pressed = [button]
        when Symbol
          if_pressed = [if_pressed]
        when Array, FalseClass
          # sono mama
        else
          raise "not support class"
        end
        hash = { if_pressed: if_pressed }
        if force_neutral
          hash[:force_neutral] = force_neutral
        end
        if flip_interval
          if /\A(\d+)F\z/i =~ flip_interval
            interval =  ((frame = $1.to_i) / 60.0).floor(2)
          else
            raise "8F みたいなフォーマットで入力してください"
          end
          hash[:flip_interval] = interval
        end
        self.flips[button] = hash
      end

      PRESET_MACROS = [:fast_return]
      def macro(name, if_pressed: )
        if name.respond_to?(:name)
          macro_name = name.name.to_sym
        else
          macro_name = name
        end
        self.macros[macro_name] = { if_pressed: if_pressed }
      end

      def remap(button, to: )
        raise "シンボル以外は設定できません" unless to.is_a?(Symbol)
        self.remaps[button] = to
      end

      # @return [Array]
      def flip_buttons
        flips
      end
    end
  end
end
