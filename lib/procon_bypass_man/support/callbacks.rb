# frozen_string_literal: true

module ProconBypassMan
  module CallbacksRegisterable
    attr_accessor :callbacks

    def register_callback_module(mod)
      self.callbacks ||= []
      callbacks << mod
      self.include(mod)
    end
  end

  module Callbacks
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
        self.__callbacks ||= {}
        self.__callbacks[kind] ||= CallbackChain.new
        self.__callbacks[kind].append Callback.new(
          filter: filter,
          chain_method: chain_method,
          block: block,
        )
      end
    end

    def self.included(mod)
      mod.singleton_class.attr_accessor :__callbacks
      mod.extend(ClassMethods)
    end

    class CallbackChain
      attr_accessor :callbacks

      def initialize
        self.callbacks = {}
      end

      def empty?
        callbacks.empty?
      end

      def append(callback)
        self.callbacks[callback.filter] ||= []
        self.callbacks[callback.filter] << callback
      end

      def [](filter)
        self.callbacks[filter]
      end
    end

    class Callback
      attr_accessor :filter, :chain_method

      def initialize(filter: , chain_method: , block: )
        @filter = filter
        @chain_method = chain_method
        @block = block
      end
    end

    # TODO haltしたらcallbackを止める
    def run_callbacks(kind, &block)
      chains = get_callbacks(kind) or raise("unknown callback")
      if chains.nil? || chains.empty?
        return block.call
      end

      chains[:before]&.each do |chain|
        send chain.chain_method
      end
      result = block.call
      chains[:after]&.each do |chain|
        send chain.chain_method
      end

      return result
    end

    def get_callbacks(kind) # :nodoc:
      # classに直接moduleをincludeしている場合
      if defined?(self.class.__callbacks) && !self.class.respond_to?(:callbacks)
        return self.class.__callbacks[kind.to_sym]
      end

      list =
        if self.class.callbacks.nil?
          []
        else
          self.class.callbacks.flat_map { |callback_mod|
            callback_mod.__callbacks && callback_mod.__callbacks[kind.to_sym]
          }.compact
        end
      if(self.class.respond_to?(:__callbacks) && chain = self.class.__callbacks[kind.to_sym])
        list << chain
      end
      table = {}
      table[:before] = list.flat_map { |x| x[:before] }.compact
      table[:after] = list.flat_map { |x| x[:after] }.compact
      table
    end
  end
end
