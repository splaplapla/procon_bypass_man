require "spec_helper"

describe ProconBypassMan::ButtonsSettingConfiguration::Layer do
  let(:layer) { ProconBypassMan::ButtonsSettingConfiguration::Layer.new }

  before do
    ProconBypassMan.reset!
  end

  describe '#flip' do
    subject { layer.flip(button, **options); layer.flips }

    context '存在するボタン' do
      let(:button) { :b }

      context 'options is empty' do
        let(:options) { {} }
        it do
          expect(subject).to eq(b: {:if_pressed=>false})
        end
      end

      describe 'if_pressed' do
        context 'is nil' do
          let(:options) { { if_pressed: nil } }
          it { expect(subject).to eq(b: {:if_pressed=>false}) }
        end
        context 'is true' do
          let(:options) { { if_pressed: true } }
          it { expect(subject).to eq(b: {:if_pressed=>[:b]}) }
        end
        context 'is symbol' do
          let(:options) { { if_pressed: :x } }
          it { expect(subject).to eq(b: {:if_pressed=>[:x]}) }
        end
        context 'is string' do
          let(:options) { { if_pressed: 'x' } }
          it { expect(subject).to eq(b: {:if_pressed=>[:x]}) }
        end
        context 'is array' do
          let(:options) { { if_pressed: ['x', 'x'] } }
          it { expect(subject).to eq(b: {:if_pressed=>[:x]}) }
        end
      end

      describe 'force_neutral' do
        context 'is true' do
          let(:options) { { force_neutral: true } }
          it { expect(subject).to be_empty }
        end
        context 'is symbol' do
          let(:options) { { force_neutral: :x } }
          it { expect(subject).to eq(:b=>{:if_pressed=>false, :force_neutral=>[:x]}) }
        end
        context 'is string' do
          let(:options) { { force_neutral: 'x' } }
          it { expect(subject).to eq(:b=>{:if_pressed=>false, :force_neutral=>[:x]}) }
        end
        context 'is array' do
          let(:options) { { force_neutral: ['x', 'x'] } }
          it { expect(subject).to eq(:b=>{:if_pressed=>false, :force_neutral=>[:x]}) }
        end
      end

      xdescribe 'flip_interval' do
      end
    end

    context '存在しないボタン' do
      let(:button) { :g }
      let(:options) { {} }
      it { expect(subject).to eq(g: {:if_pressed=>false}) }
    end

    context 'integer' do
      let(:button) { 1 }
      let(:options) { {} }
      it { expect(subject).to eq(1 => {:if_pressed=>false}) }
    end

    context 'array' do
      let(:button) { [] }
      let(:options) { {} }
      it { expect(subject).to eq([] => {:if_pressed=>false}) }
    end

    context 'nil' do
      let(:button) { nil }
      let(:options) { {} }
      it { expect(subject).to eq(nil => {:if_pressed=>false}) }
    end
  end

  describe '#macro' do
    let(:macro_class) do
      module TheMacro
        def self.steps
          [:pressing_thumbr_and_toggle_zr_for_2sec, :a]
        end
      end
      TheMacro
    end

    subject { layer.macro(macro_class, **options); layer.macros }

    context 'macroをインストール済み' do
      before do
        klass = macro_class
        ProconBypassMan.buttons_setting_configure do
          install_macro_plugin klass
        end
      end

      describe 'if_pressed' do
        context 'is nil' do
          let(:options) { { if_pressed: nil } }
          it { expect(subject).to eq({}) }
        end
        context 'is true' do
          let(:options) { { if_pressed: true } }
          it { expect(subject).to eq({}) }
        end
        context 'is symbol' do
          let(:options) { { if_pressed: :x } }
          it { expect(subject).to eq({:TheMacro => {:if_pressed=>[:x]}}) }
        end
        context 'is string' do
          let(:options) { { if_pressed: 'x' } }
          it { expect(subject).to eq({:TheMacro => {:if_pressed=>[:x]}}) }
        end
        context 'is array' do
          let(:options) { { if_pressed: ['x', 'x'] } }
          it { expect(subject).to eq({:TheMacro => {:if_pressed=>[:x]}}) }
        end
      end

      context 'valid if_pressed && if_tilted_left_stick' do
        let(:options) { { if_pressed: :x, if_tilted_left_stick: subject_value } }
        context 'is nil' do
          let(:subject_value) { nil }
          it { expect(subject).to eq({:TheMacro => {:if_pressed=>[:x] }}) }
        end
        context 'is true' do
          let(:subject_value) { true }
          it { expect(subject).to eq({:TheMacro => {:if_pressed=>[:x], if_tilted_left_stick: true }}) }
        end
        context 'is symbol' do
          let(:subject_value) { :y }
          it { expect(subject).to eq({:TheMacro => {:if_pressed=>[:x] }}) }
        end
        context 'is string' do
          let(:subject_value) { 'y' }
          it { expect(subject).to eq({:TheMacro => {:if_pressed=>[:x] }}) }
          it do
            subject
            expect(ProconBypassMan::Procon::MacroRegistry.plugins[:TheMacro].call).not_to be_nil
          end
        end
        context 'is array' do
          let(:subject_value) { ['y', 'y'] }
          it { expect(subject).to eq({:TheMacro => {:if_pressed=>[:x] } }) }
          it do
            subject
            expect(ProconBypassMan::Procon::MacroRegistry.plugins[:TheMacro].call).not_to be_nil
          end
        end
      end

      context 'valid if_pressed && force_neutral' do
        let(:options) { { if_pressed: :x, force_neutral: subject_value } }
        context 'is nil' do
          let(:subject_value) { nil }
          it { expect(subject).to eq({:TheMacro => {:if_pressed=>[:x] }}) }
        end
        context 'is true' do
          let(:subject_value) { true }
          it { expect(subject).to eq({}) }
        end
        context 'is symbol' do
          let(:subject_value) { :y }
          it { expect(subject).to eq({:TheMacro => {:if_pressed=>[:x], :force_neutral=>[:y] }}) }
        end
        context 'is string' do
          let(:subject_value) { 'y' }
          let(:options) { { if_pressed: :x, force_neutral: 'y' } }
          it { expect(subject).to eq({:TheMacro => {:if_pressed=>[:x], :force_neutral=>[:y] }}) }
        end
        context 'is array' do
          let(:subject_value) { ['y', 'y'] }
          it { expect(subject).to eq({:TheMacro => {:if_pressed=>[:x], :force_neutral=>[:y] } }) }
        end
      end
    end

    context 'macroを未インストール' do
      describe 'if_pressed' do
        context 'is nil' do
          let(:options) { { if_pressed: nil } }
          it { expect(subject).to eq({}) }
        end
        context 'is true' do
          let(:options) { { if_pressed: true } }
          it { expect(subject).to eq({}) }
        end
        context 'is symbol' do
          let(:options) { { if_pressed: :x } }
          it { expect(subject).to eq({}) }
        end
        context 'is string' do
          let(:options) { { if_pressed: 'x' } }
          it { expect(subject).to eq({}) }
        end
        context 'is array' do
          let(:options) { { if_pressed: ['x', 'x'] } }
          it { expect(subject).to eq({}) }
        end
      end
    end
  end

  describe '#open_macro' do
    subject { layer.open_macro(name, steps: steps, **options); layer.macros }

    context 'nameにnilを渡すとき' do
      let(:name ) { nil }
      let(:steps) { [] }
      let(:options) { { if_pressed: :x } }
      it { expect(subject).to eq({}) }
    end

    context 'stepsにnilを渡すとき' do
      let(:name ) { "name" }
      let(:steps) { nil }
      let(:options) { { if_pressed: :x } }
      it { expect(subject).to eq({}) }
    end

    describe 'steps' do
      let(:name ) { "name" }
      let(:steps) { subject_value }
      let(:options) { { if_pressed: :x } }
      context 'is nil' do
        let(:subject_value) { nil }
        it { expect(subject).to eq({}) }
      end
      context 'is true' do
        let(:subject_value) { true }
        it { expect(subject).to eq({}) }
      end
      context 'is symbol' do
        let(:subject_value) { :x }
        it { expect(subject).to eq({"name" => {:if_pressed=>[:x]}}) }
        it do
          subject
          expect(ProconBypassMan::Procon::MacroRegistry.plugins[:name].call).to eq([:x])
        end
      end
      context 'is string' do
        let(:subject_value) { "x" }
        it { expect(subject).to eq({"name" => {:if_pressed=>[:x]}}) }
        it do
          subject
          expect(ProconBypassMan::Procon::MacroRegistry.plugins[:name].call).to eq([:x])
        end
      end
      context 'is array' do
        let(:subject_value) { ["x", "x"] }
        it { expect(subject).to eq({"name" => {:if_pressed=>[:x]}}) }
        it do
          subject
          expect(ProconBypassMan::Procon::MacroRegistry.plugins[:name].call).to eq([:x])
        end
      end
    end

    context 'nameとstepsに値があるとき' do
      let(:name ) { "name" }
      let(:steps) { [] }

      context 'macroをインストール済み' do
        describe 'if_pressed' do
          context 'is nil' do
            let(:options) { { if_pressed: nil } }
            it { expect(subject).to eq({}) }
          end
          context 'is true' do
            let(:options) { { if_pressed: true } }
            it { expect(subject).to eq({}) }
          end
          context 'is symbol' do
            let(:options) { { if_pressed: :x } }
            it { expect(subject).to eq({"name" => {:if_pressed=>[:x]}}) }
          end
          context 'is string' do
            let(:options) { { if_pressed: 'x' } }
            it { expect(subject).to eq({"name" => {:if_pressed=>[:x]}}) }
          end
          context 'is array' do
            let(:options) { { if_pressed: ['x', 'x'] } }
            it { expect(subject).to eq({"name" => {:if_pressed=>[:x]}}) }
          end
        end

        context 'valid if_pressed && if_tilted_left_stick' do
          let(:options) { { if_pressed: :x, if_tilted_left_stick: subject_value } }
          context 'is nil' do
            let(:subject_value) { nil }
            it { expect(subject).to eq({"name" => {:if_pressed=>[:x] }}) }
          end
          context 'is true' do
            let(:subject_value) { true }
            it { expect(subject).to eq({"name" => {:if_pressed=>[:x], if_tilted_left_stick: true }}) }
          end
          context 'is symbol' do
            let(:subject_value) { :y }
            it { expect(subject).to eq({"name" => {:if_pressed=>[:x] }}) }
          end
          context 'is string' do
            let(:subject_value) { 'y' }
            it { expect(subject).to eq({"name" => {:if_pressed=>[:x] }}) }
          end
          context 'is array' do
            let(:subject_value) { ['y', 'y'] }
            it { expect(subject).to eq({"name" => {:if_pressed=>[:x] } }) }
          end
        end

        context 'valid if_pressed && force_neutral' do
          let(:options) { { if_pressed: :x, force_neutral: subject_value } }
          context 'is nil' do
            let(:subject_value) { nil }
            it { expect(subject).to eq({"name" => {:if_pressed=>[:x] }}) }
          end
          context 'is true' do
            let(:subject_value) { true }
            it { expect(subject).to eq({}) }
          end
          context 'is symbol' do
            let(:subject_value) { :y }
            it { expect(subject).to eq({"name" => {:if_pressed=>[:x], :force_neutral=>[:y] }}) }
          end
          context 'is string' do
            let(:subject_value) { 'y' }
            let(:options) { { if_pressed: :x, force_neutral: 'y' } }
            it { expect(subject).to eq({"name" => {:if_pressed=>[:x], :force_neutral=>[:y] }}) }
          end
          context 'is array' do
            let(:subject_value) { ['y', 'y'] }
            it { expect(subject).to eq({"name" => {:if_pressed=>[:x], :force_neutral=>[:y] } }) }
          end
        end
      end
    end
  end
end
