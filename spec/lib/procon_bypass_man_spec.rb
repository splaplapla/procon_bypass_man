require "spec_helper"

describe ProconBypassMan do
  describe '.configure' do
    describe 'layer' do
      context 'with auto mode' do
        it do
          described_class.configure do
            layer :up do
              flip :l, if_pushed: true
              flip :r
            end
            layer :down, mode: :manual do
              flip :r, if_pushed: [:zr, :zl]
            end
            layer :right, mode: :auto
            layer :left
          end
          expect(ProconBypassMan::Configuration.instance.layers[:up].flip_buttons[:l]).to eq(if_pushed: true)
          expect(ProconBypassMan::Configuration.instance.layers[:up].flip_buttons[:r]).to eq(if_pushed: false)
          expect(ProconBypassMan::Configuration.instance.layers[:up].flip_buttons.keys).to eq([:l, :r])
          expect(ProconBypassMan::Configuration.instance.layers[:down].flip_buttons.keys).to eq([:r])
          expect(ProconBypassMan::Configuration.instance.layers[:down].flip_buttons[:r]).to eq(if_pushed: [:zr, :zl])
          expect(ProconBypassMan::Configuration.instance.layers[:down].mode).to eq(:manual)
          expect(ProconBypassMan::Configuration.instance.layers[:right].flip_buttons.keys).to eq([])
          expect(ProconBypassMan::Configuration.instance.layers[:right].mode).to eq(:auto)
          expect(ProconBypassMan::Configuration.instance.layers[:left].flip_buttons.keys).to eq([])
          expect(ProconBypassMan::Configuration.instance.layers[:left].mode).to eq(:manual)
        end
      end
      context 'has values' do
        it do
          described_class.configure do
            layer :up do
              flip :l
              flip :r
            end
            layer :down do
              flip :r
            end
            layer :right
            layer :left
          end
          expect(ProconBypassMan::Configuration.instance.layers[:up].flip_buttons.keys).to eq([:l, :r])
          expect(ProconBypassMan::Configuration.instance.layers[:down].flip_buttons.keys).to eq([:r])
          expect(ProconBypassMan::Configuration.instance.layers[:right].flip_buttons.keys).to eq([])
          expect(ProconBypassMan::Configuration.instance.layers[:left].flip_buttons.keys).to eq([])
        end
      end
      context '全部空' do
        it do
          described_class.configure do
            layer :up do
            end
            layer :down do
            end
            layer :right do
            end
            layer :left do
            end
          end
          expect(ProconBypassMan::Configuration.instance.layers[:up].flip_buttons.keys).to eq([])
          expect(ProconBypassMan::Configuration.instance.layers[:down].flip_buttons.keys).to eq([])
          expect(ProconBypassMan::Configuration.instance.layers[:right].flip_buttons.keys).to eq([])
          expect(ProconBypassMan::Configuration.instance.layers[:left].flip_buttons.keys).to eq([])
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
