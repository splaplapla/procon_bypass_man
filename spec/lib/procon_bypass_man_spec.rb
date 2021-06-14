require "spec_helper"

describe ProconBypassMan do
  describe '.configure' do
    describe 'layer' do
      context 'with random mode' do
        it do
          described_class.configure do
            layer :up do
              flip [:l, :r]
            end
            layer :down, mode: :normal do
              flip [:r]
            end
            layer :right, mode: :random
            layer :left
          end
          expect(ProconBypassMan::Configuration.instance.layers[:up].flip_buttons).to eq([:l, :r])
          expect(ProconBypassMan::Configuration.instance.layers[:down].flip_buttons).to eq([:r])
          expect(ProconBypassMan::Configuration.instance.layers[:down].mode).to eq(:normal)
          expect(ProconBypassMan::Configuration.instance.layers[:right].flip_buttons).to eq([])
          expect(ProconBypassMan::Configuration.instance.layers[:right].mode).to eq(:random)
          expect(ProconBypassMan::Configuration.instance.layers[:left].flip_buttons).to eq([])
          expect(ProconBypassMan::Configuration.instance.layers[:left].mode).to eq(:normal)
        end
      end
      context 'has values' do
        it do
          described_class.configure do
            layer :up do
              flip [:l, :r]
            end
            layer :down do
              flip [:r]
            end
            layer :right
            layer :left do
              flip []
            end
          end
          expect(ProconBypassMan::Configuration.instance.layers[:up].flip_buttons).to eq([:l, :r])
          expect(ProconBypassMan::Configuration.instance.layers[:down].flip_buttons).to eq([:r])
          expect(ProconBypassMan::Configuration.instance.layers[:right].flip_buttons).to eq([])
          expect(ProconBypassMan::Configuration.instance.layers[:left].flip_buttons).to eq([])
        end
      end
      context '全部空' do
        it do
          described_class.configure do
            layer :up do
              flip []
            end
            layer :down do
              flip []
            end
            layer :right do
              flip []
            end
            layer :left do
              flip []
            end
          end
          expect(ProconBypassMan::Configuration.instance.layers[:up].flip_buttons).to eq([])
          expect(ProconBypassMan::Configuration.instance.layers[:down].flip_buttons).to eq([])
          expect(ProconBypassMan::Configuration.instance.layers[:right].flip_buttons).to eq([])
          expect(ProconBypassMan::Configuration.instance.layers[:left].flip_buttons).to eq([])
        end
      end
    end
    describe 'prefix_keys_for_changing_layer' do
      it do
        described_class.configure do
          prefix_keys_for_changing_layer [:zr]
        end
        expect(ProconBypassMan::Configuration.instance.prefix_keys).to eq([:zr])
      end
    end
  end
end
