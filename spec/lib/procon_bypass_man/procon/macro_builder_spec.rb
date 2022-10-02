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
      describe 'toggle + 存在しないボタン' do
        it do
          expect(described_class.new([:toggle_v]).build).to eq([:none])
        end
      end

      describe 'toggle' do
        it do
          expect(described_class.new([:toggle_a]).build).to eq([
            :a, :none
          ])
        end
        it do
          expect(described_class.new([:toggle_a, :toggle_b]).build).to eq([:a, :none, :b, :none])
        end
        it do
          expect(described_class.new([:a, :toggle_b, :sl, :toggle_b, :b]).build).to eq([:a, :b, :none, :sl, :b, :none, :b])
        end
      end

      describe 'toggle_x_for_2sec' do
        it do
          expect(described_class.new([:toggle_a_for_2sec]).build).to eq(
            [{ continue_for: 2, steps: [:a, :none] }]
          )
        end
        it do
          expect(described_class.new([:toggle_b, :toggle_a_for_3sec]).build).to eq(
            [ :b,
              :none,
              { continue_for: 3, steps: [:a, :none] }
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

      describe 'pressing_r_and_toggle_zr' do
        it do
          expect(described_class.new([:pressing_r_and_toggle_zr]).build).to eq([
            [:r, :zr],
            [:r, :none],
          ])
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

      describe 'pressing_zr_and_toggle_b_for_0_65sec' do
        it do
          expect(described_class.new([:pressing_zr_and_toggle_b_for_0_65sec]).build).to eq(
            [{ continue_for: 0.65, steps: [
              [:zr, :b],
              [:zr, :none],
            ] }]
          )
        end

        it do
          expect(described_class.new([:pressing_zr_and_toggle_b_for_0_65]).build).to eq(
            [{ continue_for: 0.65, steps: [
              [:zr, :b],
              [:zr, :none],
            ] }]
          )
        end
      end

      describe 'wait_for_0_65sec' do
        it do
          expect(described_class.new([:wait_for_0_65sec]).build).to eq(
            [{ continue_for: 0.65, steps: [
              :none,
            ] }]
          )
        end

        it do
          expect(described_class.new([:wait_for_0_5]).build).to eq(
            [{ continue_for: 0.5, steps: [
              :none,
            ] }]
          )
        end
      end

      describe 'rotate_left_stick_for_forward_ikarole' do
        it do
          expect(described_class.new([:rotate_left_stick_for_forward_ikarole, :pressing_b_for_0_03sec, :wait_for_0_02sec]).build).to eq([
             :tilt_left_stick_completely_to_90deg,
             :tilt_left_stick_completely_to_180deg,
             :tilt_left_stick_completely_to_270deg,
             :tilt_left_stick_completely_to_0deg,
             { continue_for: 0.03, steps: [:b, :b] },
             {:continue_for=>0.02, :steps=>[:none] },
          ])
        end
      end

      describe 'shake_left_stick' do
        it do
          expect(described_class.new([:shake_left_stick_for_0_65sec]).build).to eq([
            { continue_for: 0.65, steps: [
                :tilt_left_stick_completely_to_left,
                :tilt_left_stick_completely_to_right,
              ]
            }
          ])
        end

        it do
          expect(described_class.new([:shake_left_stick_and_toggle_b_for_0_65sec]).build).to eq([
            { continue_for: 0.65, steps: [
              [:tilt_left_stick_completely_to_left, :b],
              [:tilt_left_stick_completely_to_right, :none],
            ]}
          ])
        end

        it do
          expect(described_class.new([:shake_left_stick_and_toggle_b_and_pressing_r_for_0_65sec]).build).to eq([
            { continue_for: 0.65, steps: [
              [:tilt_left_stick_completely_to_left, :b, :r],
              [:tilt_left_stick_completely_to_right, :none, :r],
            ]}
          ])
        end

        it do
          expect(described_class.new([:toggle_b_and_shake_left_stick_and_pressing_r_for_0_65sec]).build).to eq([
            { continue_for: 0.65, steps: [
              [:b, :tilt_left_stick_completely_to_left, :r],
              [:none, :tilt_left_stick_completely_to_right, :r],
            ]}
          ])
        end

        it do
          expect(described_class.new([:toggle_b_and_shake_left_stick_and_pressing_r_for_0_06sec]).build).to eq([
            { continue_for: 0.06, steps: [
              [:b, :tilt_left_stick_completely_to_left, :r],
              [:none, :tilt_left_stick_completely_to_right, :r],
            ]}
          ])
        end
      end
    end
  end
end
