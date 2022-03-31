module ProconBypassMan
  class ButtonsSettingConfiguration
    module ParamNormalizer
      class ButtonList
        attr_reader :button

        def initialize(button)
          @button = button
        end

        # @return [Array]
        def to_a
          case button
          when TrueClass, FalseClass, NilClass
            Kernel.warn "設定ファイルに記述ミスがあります. disableにはボタンを渡してください."
            return
          when Symbol
            return [button]
          when String
            return [button.to_sym]
          when Array
            return button.map(&:to_sym).uniq
          else
            Kernel.warn "設定ファイルに記述ミスがあります. disableで未対応の値を受け取りました."
            return
          end
        end
      end
    end
  end
end
