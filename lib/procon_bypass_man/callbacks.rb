module ProconBypassMan
  module Callbacks
    class CallbacksChain
      attr_accessor :filter, :chain_method
      def initialize(filter: , chain_method: , block: )
        @filter = filter
        @chain_method = chain_method
        @block = block
      end
    end

    # TODO __callbacksをincludeしたクラス側で保持する. 今はnemespaceがない
    module M
      class << self
        attr_accessor :__callbacks
      end
    end

    module ClassMethods
      def define_callbacks(name)
        self.singleton_class.attr_accessor "_#{name}_callbacks"
        send "_#{name}_callbacks=", [name] # CallbacksChain

        module_eval <<-RUBY, __FILE__, __LINE__ + 1
          def _run_#{name}_callbacks(&block)
            __run_callbacks__(_#{name}_callbacks, &block)
          end
        RUBY
      end

      def set_callback(kind, filter, chain_method, &block)
        ProconBypassMan::Callbacks::M.__callbacks ||= {}
        ProconBypassMan::Callbacks::M.__callbacks[kind] = CallbacksChain.new(
          filter: filter,
          chain_method: chain_method,
          block: block,
        )
      end
    end

    # TODO haltしたらcallbackを止める
    # TODO 複数をチェインできるようにする
    def run_callbacks(kind, &block)
      chain = get_callbacks(kind) or raise("unknown callback")
      case chain.filter
      when :before
        send chain.chain_method
        block.call
      when :after
        block.call
        send chain.chain_method
      else
        raise("unknown filter")
      end
    end

    # def __run_callbacks__(name, &block)
    #   puts "called"
    # end

    def get_callbacks(kind) # :nodoc:
      ProconBypassMan::Callbacks::M.__callbacks[kind.to_sym]
    end

    def set_callbacks(name, callbacks) # :nodoc:
      send "_#{name}_callbacks=", callbacks
      ProconBypassMan::Callbacks::M.__callbacks[kind.to_sym] = callbacks
    end
  end
end
