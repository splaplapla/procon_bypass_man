require "spec_helper"

describe ProconBypassMan::Procon::Macro do
  describe 'v1 format' do
    describe '#next_step' do
      it do
        macro = described_class.new(name: nil, steps: [:a, :b])
        expect(macro.next_step).to eq(:a)
        expect(macro.next_step).to eq(:b)
        expect(macro.next_step).to eq(nil)
        expect(macro.next_step).to eq(nil)
      end
    end

    describe '#finished?' do
      context 'stespがあるとき' do
        it do
          macro = described_class.new(name: nil, steps: [:a, :b])
          expect(macro.finished?).to eq(false)
        end
      end

      context 'stespがないとき' do
        it do
          macro = described_class.new(name: nil, steps: [])
          expect(macro.finished?).to eq(true)
        end
      end
    end

    describe '#ongoing?' do
      context 'stespがあるとき' do
        it do
          macro = described_class.new(name: nil, steps: [:a, :b])
          expect(macro.ongoing?).to eq(true)
        end
      end

      context 'stespがないとき' do
        it do
          macro = described_class.new(name: nil, steps: [])
          expect(macro.ongoing?).to eq(false)
        end
      end
    end
  end

  describe 'v2 format' do
    describe '#next_step' do
      context '時間が空かないとき' do
        let(:nested_step) {
          { continue_for: 3, steps: [:r, :none], }
        }
        it do
          macro = described_class.new(name: nil, steps: [nested_step])
          expect(macro.next_step).to eq(:r)
          expect(macro.next_step).to eq(:none)
          expect(macro.next_step).to eq(:r)
          expect(macro.next_step).to eq(:none)
        end
      end

      context '時間が空くとき' do
        context 'nested_stepのみ' do
          let(:nested_step) {
            { continue_for: 3, steps: [:r, :none], }
          }
          it do
            macro = described_class.new(name: nil, steps: [nested_step])
            Timecop.freeze '2021-11-11 00:00:00' do
              expect(macro.next_step).to eq(:r)
              expect(macro.next_step).to eq(:none)
              expect(macro.next_step).to eq(:r)
              expect(macro.next_step).to eq(:none)
            end

            Timecop.freeze '2021-11-11 00:00:05' do
              expect(macro.next_step).to eq(nil)
            end
          end
        end

        context 'nested_stepが続くとき' do
          let(:nested_step) {
            { continue_for: 3, steps: [:r, :none], }
          }
          let(:nested_step2) {
            { continue_for: 3, steps: [:r, :none], }
          }
          it do
            macro = described_class.new(name: nil, steps: [nested_step, nested_step2])
            Timecop.freeze '2021-11-11 00:00:00' do
              expect(macro.next_step).to eq(:r)
              expect(macro.next_step).to eq(:none)
              expect(macro.next_step).to eq(:r)
              expect(macro.next_step).to eq(:none)
            end

            Timecop.freeze '2021-11-11 00:00:05' do
              expect(macro.next_step).to eq(:r)
              expect(macro.next_step).to eq(:none)
            end

            Timecop.freeze '2021-11-11 00:00:09' do
              expect(macro.next_step).to eq(nil)
              expect(macro.next_step).to eq(nil)
            end
          end
        end

        context 'nested_stepとv1を含むとき' do
          let(:nested_step) {
            { continue_for: 3, steps: [:r, :none], }
          }
          it do
            macro = described_class.new(name: nil, steps: [nested_step, :a])
            Timecop.freeze '2021-11-11 00:00:00' do
              expect(macro.next_step).to eq(:r)
              expect(macro.next_step).to eq(:none)
              expect(macro.next_step).to eq(:r)
              expect(macro.next_step).to eq(:none)
            end

            Timecop.freeze '2021-11-11 00:00:05' do
              expect(macro.next_step).to eq(:a)
              expect(macro.next_step).to eq(nil)
            end
          end
        end
      end
    end
  end
end
