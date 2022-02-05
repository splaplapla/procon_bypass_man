require "spec_helper"

describe ProconBypassMan::Procon::MacroBuilder do
  describe '#build' do
    describe 'v1 format' do
      context '存在するボタン' do
        let(:buttons) { [:y, :x, :b, :a, :sl, :sr, :r, :zr, :minus, :plus, :thumbr, :thumbl, :home, :cap, :down, :up, :right, :left, :l, :zl] }
        it 'そのまま返すこと' do
          expect(described_class.new(buttons).build).to eq(buttons)
        end
      end

      context '存在するボタン + ゴミ' do
        let(:buttons) { [:y, :x, :b, :a, :sl, :sr, :r, :zr, :minus, :plus, :thumbr, :thumbl, :home, :cap, :down, :up, :right, :left, :l, :zl] }
        let(:not_exists_buttons) { [:foo, :bar] }
        it 'そのまま返すこと' do
          expect(described_class.new(buttons + not_exists_buttons).build).to eq(buttons)
        end
      end

      context '予約語' do
        it 'そのまま返すこと' do
          expect(described_class.new([:none]).build).to eq([:none])
        end
      end
    end

    describe 'v2 format' do
      describe 'toggle' do
        it do
          expect(described_class.new([:toggle_r]).build).to eq([:r, :none])
        end
        it do
          expect(described_class.new([:toggle_r, :toggle_b]).build).to eq([:r, :none, :b, :none])
        end
        it do
          expect(described_class.new([:a, :toggle_r, :sl, :toggle_b, :b]).build).to eq([:a, :r, :none, :sl, :b, :none, :b])
        end
      end

      describe 'toggle_x_for_2sec' do
        it do
          expect(described_class.new([:toggle_r_for_2sec]).build).to eq(
            [{ continue_for: 2, steps: [:r, :none] }]
          )
        end
        it do
          expect(described_class.new([:toggle_r, :toggle_r_for_3sec]).build).to eq(
            [ :r,
              :none,
              { continue_for: 3, steps: [:r, :none] }
            ]
          )
        end
      end

      describe 'toggle_x_for_0_2sec' do
        it do
          expect(described_class.new([:toggle_r_for_0_2sec]).build).to eq(
            [{ continue_for: 0.2, steps: [:r, :none] }]
          )
        end
        it do
          expect(described_class.new([:toggle_r, :toggle_r_for_0_3sec]).build).to eq(
            [ :r,
              :none,
              { continue_for: 0.3, steps: [:r, :none] }
            ]
          )
        end
      end

      describe 'pressing_x_for_2sec' do
        it do
          expect(described_class.new([:pressing_x_for_2sec]).build).to eq(
            [{ continue_for: 2, steps: [:x, :x] }]
          )
        end
      end

      describe 'pressing_x_for_0_2sec' do
        it do
          expect(described_class.new([:pressing_x_for_0_2sec]).build).to eq(
            [{ continue_for: 0.2, steps: [:x, :x] }]
          )
        end
      end

      describe 'pressing_x_for_0_2sec' do
        it do
          expect(described_class.new([:pressing_x_for_0_2sec]).build).to eq(
            [{ continue_for: 0.2, steps: [:x, :x] }]
          )
        end
      end

      describe 'pressing_x_and_toggle_zr_for_0_2sec' do
        it do
          expect(described_class.new([:pressing_x_and_toggle_zr_for_0_2sec]).build).to eq(
            [{ continue_for: 0.2, steps: [
              [:x, :zr],
              [:x, :none],
            ] }]
          )
        end
      end

      describe 'pressing_x_and_toggle_zr_for_0_2sec' do
        it do
          expect(described_class.new([:pressing_x_and_toggle_zr_for_0_2sec]).build).to eq(
            [{ continue_for: 0.2, steps: [
              [:x, :zr],
              [:x, :none],
            ] }]
          )
        end
      end

      describe 'toggle_x_and_toggle_zr_for_0_2sec' do
        it do
          expect(described_class.new([:toggle_x_and_toggle_zr_for_0_2sec]).build).to eq(
            [{ continue_for: 0.2, steps: [
              [:x, :zr],
              [:none, :none],
            ] }]
          )
        end
      end

      describe 'pressing_x_and_pressing_zr_for_0_2sec' do
        it do
          expect(described_class.new([:pressing_x_and_pressing_zr_for_0_2sec]).build).to eq(
            [{ continue_for: 0.2, steps: [
              [:x, :zr],
              [:x, :zr],
            ] }]
          )
        end
      end

      describe 'pressing_thumbr_and_toggle_zr_for_0_6sec' do
        it do
          expect(described_class.new([:pressing_thumbr_and_toggle_zr_for_0_6sec]).build).to eq(
            [{ continue_for: 0.6, steps: [
              [:thumbr, :zr],
              [:thumbr, :none],
            ] }]
          )
        end
      end

      describe 'pressing_zr_and_toggle_b_for_0_6sec' do
        it do
          expect(described_class.new([:pressing_zr_and_toggle_b_for_0_6sec]).build).to eq(
            [{ continue_for: 0.6, steps: [
              [:zr, :b],
              [:zr, :none],
            ] }]
          )
        end
      end
    end
  end
end
