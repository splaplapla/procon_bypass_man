require "spec_helper"

describe ProconBypassMan::ButtonsSettingConfiguration::Layer do
  let(:layer) { ProconBypassMan::ButtonsSettingConfiguration::Layer.new }

  describe '#flip' do
    subject { layer.flip(button, **options) }

    before { subject }

    context '存在するボタン' do
      let(:button) { :b }

      context 'options is empty' do
        let(:options) { {} }
        it do
          subject
          expect(layer.flips).to eq(b: {:if_pressed=>false})
        end
      end

      describe 'if_pressed' do
        context 'is nil' do
          let(:options) { { if_pressed: nil } }
          it { expect(layer.flips).to eq(b: {:if_pressed=>false}) }
        end
        context 'is true' do
          let(:options) { { if_pressed: true } }
          it { expect(layer.flips).to eq(b: {:if_pressed=>[:b]}) }
        end
        context 'is symbol' do
          let(:options) { { if_pressed: :x } }
          it { expect(layer.flips).to eq(b: {:if_pressed=>[:x]}) }
        end
        context 'is string' do
          let(:options) { { if_pressed: 'x' } }
          it { expect(layer.flips).to eq(b: {:if_pressed=>[:x]}) }
        end
        context 'is array' do
          let(:options) { { if_pressed: ['x', 'x'] } }
          it { expect(layer.flips).to eq(b: {:if_pressed=>[:x]}) }
        end
      end

      describe 'force_neutral' do
        context 'is true' do
          let(:options) { { force_neutral: true } }
          it { expect(layer.flips).to be_empty }
        end
        context 'is symbol' do
          let(:options) { { force_neutral: :x } }
          it { expect(layer.flips).to eq(:b=>{:if_pressed=>false, :force_neutral=>[:x]}) }
        end
        context 'is string' do
          let(:options) { { force_neutral: 'x' } }
          it { expect(layer.flips).to eq(:b=>{:if_pressed=>false, :force_neutral=>[:x]}) }
        end
        context 'is array' do
          let(:options) { { force_neutral: ['x', 'x'] } }
          it { expect(layer.flips).to eq(:b=>{:if_pressed=>false, :force_neutral=>[:x]}) }
        end
      end

      xdescribe 'flip_interval' do
      end
    end

    context '存在しないボタン' do
      let(:button) { :g }
      let(:options) { {} }
      it do
        expect(layer.flips).to eq(g: {:if_pressed=>false})
      end
    end

    context 'integer' do
      let(:button) { 1 }
      let(:options) { {} }
      it do
        expect(layer.flips).to eq(1 => {:if_pressed=>false})
      end
    end

    context 'array' do
      let(:button) { [] }
      let(:options) { {} }
      it do
        expect(layer.flips).to eq([] => {:if_pressed=>false})
      end
    end

    context 'nil' do
      let(:button) { nil }
      let(:options) { {} }
      it do
        expect(layer.flips).to eq(nil => {:if_pressed=>false})
      end
    end
  end
end
