require "spec_helper"

describe ProconBypassMan::Callbacks do
  context 'do not has super calss' do
    context 'when use a set_callback' do
      let(:klass) do
        Class.new do
          extend ProconBypassMan::Callbacks::ClassMethods
          include ProconBypassMan::Callbacks

          attr_accessor :called

          define_callbacks :call
          set_callback :call, :after, :callback_method

          def call
            @called = [:before]
            run_callbacks :call do
              @called << :call
            end
            @called << :after
          end

          def callback_method
            @called << :callback
          end
        end
      end

      it do
        s = klass.new
        s.call
        expect(s.called).to eq([:before, :call, :callback, :after])
      end
    end

    context 'when use two set_callbacks' do
      let(:klass) do
        Class.new do
          extend ProconBypassMan::Callbacks::ClassMethods
          include ProconBypassMan::Callbacks

          attr_accessor :called

          define_callbacks :call

          set_callback :call, :before, :before_hook_method
          set_callback :call, :after, :after_hook_method

          def call
            @called = [:before]
            run_callbacks :call do
              @called << :call
            end
            @called << :after
          end

          def before_hook_method
            @called << :callback_in_before
          end

          def after_hook_method
            @called << :callback_in_after
          end
        end
      end

      it do
        s = klass.new
        s.call
        expect(s.called).to eq([:before, :callback_in_before, :call, :callback_in_after, :after])
      end
    end
  end

  context 'has super calss' do
    let(:super_class) do
      Class.new do
        extend ProconBypassMan::Callbacks::ClassMethods
        include ProconBypassMan::Callbacks

        attr_accessor :called

        define_callbacks :call

        def call
          @called = [:before]
          run_callbacks :call do
            @called << :call
          end
          @called << :after
        end
      end
    end

    let(:sub_class_has_before_callback) do
      Class.new(super_class) do
        set_callback :call, :before, :callback_method
        def callback_method
          @called << :callback
        end
      end
    end

    let(:sub_class_has_after_callback) do
      Class.new(super_class) do
        set_callback :call, :after, :callback_method
        def callback_method
          @called << :callback
        end
      end
    end

    it do
      s = sub_class_has_before_callback.new
      s.call
      expect(s.called).to eq([:before, :callback, :call, :after])
    end

    it do
      s = sub_class_has_after_callback.new
      s.call
      expect(s.called).to eq([:before, :call, :callback, :after])
    end
  end
end
