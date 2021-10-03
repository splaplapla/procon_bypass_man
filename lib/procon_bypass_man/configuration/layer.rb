module ProconBypassMan
  class Configuration
    class Layer
      attr_accessor :mode, :flips, :macros, :remaps, :left_analog_stick_caps

      def initialize(mode: :manual)
        self.mode = mode
        self.flips = {}
        self.macros = {}
        self.remaps = {}
        self.left_analog_stick_caps = {}
        instance_eval(&block) if block_given?
      end

      # @param [Symbol] button
      def flip(button, if_pressed: false, force_neutral: nil, flip_interval: nil)
        case if_pressed
        when TrueClass
          if_pressed = [button]
        when Symbol, String
          if_pressed = [if_pressed]
        when Array, FalseClass
          # sono mama
        else
          raise "not support class"
        end
        hash = { if_pressed: if_pressed }
        if force_neutral
          case force_neutral
          when TrueClass, FalseClass
            raise "ボタンを渡してください"
          when Symbol, String
            hash[:force_neutral] = [force_neutral]
          when Array
            hash[:force_neutral] = force_neutral
          end
        end

        if flip_interval
          if /\A(\d+)F\z/i =~ flip_interval
            interval =  ((frame = $1.to_i) / 60.0).floor(2)
          else
            raise "8F みたいなフォーマットで入力してください"
          end
          hash[:flip_interval] = interval
        end
        if self.flips[button]
          raise "#{button}への設定をすでに割り当て済みです"
        else
          self.flips[button] = hash
        end
      end

      def macro(name, if_pressed: )
        if name.respond_to?(:name)
          macro_name = name.name.to_sym
        else
          macro_name = name
        end
        self.macros[macro_name] = { if_pressed: if_pressed }
      end

      def remap(button, to: )
        case to
        when TrueClass, FalseClass
          raise "ボタンを渡してください"
        when Symbol, String
          self.remaps[button] = { to: [to] }
        when Array
          raise "ボタンを渡してください" if to.size.zero?
          self.remaps[button] = { to: to }
        end
      end

      def left_analog_stick_cap(x: , y: , if_pressed: nil)
        case if_pressed
        when TrueClass
          raise "not support class"
        when Symbol, String
          if_pressed = [if_pressed]
        when Array, FalseClass
          # sono mama
        when NilClass
          if_pressed = nil
        else
          raise "not support class"
        end

        left_analog_stick_caps << {
          if_pressed => { position: { x: x, y: y } }
        }
      end

      # @return [Array]
      def flip_buttons
        flips
      end
    end
  end
end
