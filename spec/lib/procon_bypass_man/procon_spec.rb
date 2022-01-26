require "spec_helper"

describe ProconBypassMan::Procon do
  let(:binary) { [data].pack("H*") }

  before(:each) do
    ProconBypassMan.reset!
  end

  context 'with disable' do
    let(:pressed_y_and_b) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }
    let(:data) { pressed_y_and_b }
    it do
      ProconBypassMan.buttons_setting_configure do
        prefix_keys_for_changing_layer [:zr]
        layer :up do
          disable [:y]
        end
      end
      procon = ProconBypassMan::Procon.new(binary)
      expect(procon.user_operation.pressed_y?).to eq(true)
      expect(procon.user_operation.pressed_b?).to eq(true)

      procon = ProconBypassMan::Procon.new(procon.to_binary)
      expect(procon.user_operation.pressed_y?).to eq(false)
      expect(procon.user_operation.pressed_b?).to eq(true)
    end
  end

  context 'with left_analog_stick_caps' do
    let(:data) { "30f28100800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000" } # no_action
    it do
      ProconBypassMan.buttons_setting_configure do
        prefix_keys_for_changing_layer [:zr]
        layer :up do
          left_analog_stick_cap cap: 1000, if_pressed: [:a]
        end
      end
      procon = ProconBypassMan::Procon.new(binary)
      procon.user_operation.press_button(:a)
      expect(procon.user_operation).to receive(:apply_left_analog_stick_cap).once
      ProconBypassMan::Procon.new(procon.to_binary)
    end
  end

  context 'with flip_interval' do
    let(:data) { "30f28100800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000" } # no_action
    it do
      Timecop.freeze(Time.parse("2011-11-11 10:00:00 +09:00")) do
        ProconBypassMan::Procon::FlipCache.reset!
        ProconBypassMan.buttons_setting_configure do
          prefix_keys_for_changing_layer [:zr]
          layer :up do
            flip :zr, flip_interval: "60F"
          end
        end
        procon = ProconBypassMan::Procon.new(binary)
        procon.apply!
        expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_zr?).to eq(false)

        procon = ProconBypassMan::Procon.new(binary)
        procon.apply!
        expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_zr?).to eq(false)
      end

      Timecop.freeze(Time.parse("2011-11-11 10:00:02 +09:00")) do
        procon = ProconBypassMan::Procon.new(binary)
        procon.apply!
        expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_zr?).to eq(true)
      end
    end
  end

  context 'with mode' do
    let(:data) { "30f28100800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000" } # no_action
    let(:pressed_y_and_b) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }
    let(:not_pressed_y_and_b) { "30f28100800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000" }
    it 'modeのbinariesを繰り返すこと' do
      module G
        def self.name
          :guruguru
        end
        def self.binaries
          [ "306791c080c4c877734558740aed017b03b20f84fff8fff8ffee01a203990f9cfffffffcffed01c1038c0fb8ff04000100000000000000000000000000000000",
          ]
        end
      end
      module FastReturn
        def self.name
          :fast_return
        end

        def self.steps
          [:down, :a, :a, :x, :down, :a, :a].freeze
        end
      end
      ProconBypassMan.buttons_setting_configure do
        install_mode_plugin G
        install_macro_plugin FastReturn
        prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
        layer :up, mode: :manual do
          flip :zr, if_pressed: :zr, force_neutral: :zl
          flip :zl, if_pressed: [:y, :b, :zl]
          flip :down, if_pressed: :down
          macro :fast_return, if_pressed: [:y, :b, :down]
        end
        layer :right, mode: G
      end
      %w(
        306791c080c4c877734558740aed017b03b20f84fff8fff8ffee01a203990f9cfffffffcffed01c1038c0fb8ff04000100000000000000000000000000000000
        306991c080c4c987734758740af2011c03ef0f5bffe2ffedffe8013403e00f70fff0fff4ffe8014a03cb0f6effeefff2ff000000000000000000000000000000
        306c91c080c0c897734938740a4d02b502f70f43ffbeffceff2f02d7020f1045ffc7ffddff1902ec020c1045ffc9ffddff000000000000000000000000000000
        307091c080c0c877734928740ac901a102ca1057ffe2ffb1ff59024502601046ffcbffb9ff8d024802b50f45ffc4ffbdff000000000000000000000000000000
        307591c08000c897734c68740cf801b802cb0fafff2800e5ff0d02aa02ec0fb2ff1a00e3fff701c6022d10abff0900ddff000000000000000000000000000000
      ).each do |d|
        procon = ProconBypassMan::Procon.new([d].pack("H*"))
        procon.apply!
        procon.to_binary
      end
    end
    it 'modeのbinariesを繰り返すこと' do
      plugin = OpenStruct.new(name: :hoge, binaries: [pressed_y_and_b, not_pressed_y_and_b])
      ProconBypassMan.buttons_setting_configure do
        install_mode_plugin(plugin)
        prefix_keys_for_changing_layer [:zr]
        layer :up, mode: plugin
      end
      procon = ProconBypassMan::Procon.new(binary)
      procon.apply!
      expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_y?).to eq(true)
      expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_b?).to eq(true)

      procon = ProconBypassMan::Procon.new(binary)
      procon.apply!
      procon.to_binary
      expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_y?).to eq(false)
      expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_b?).to eq(false)

      procon = ProconBypassMan::Procon.new(binary)
      procon.apply!
      procon.to_binary
      expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_y?).to eq(true)
      expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_b?).to eq(true)
    end
    it "can't modify frozen Stringが起きないこと" do
      plugin = OpenStruct.new(name: :hoge, binaries: [ pressed_y_and_b, not_pressed_y_and_b ])
      ProconBypassMan.buttons_setting_configure do
        install_mode_plugin(plugin)
        prefix_keys_for_changing_layer [:zr]
        layer :up do
          flip :down, if_pressed: :down
        end
        layer :right, mode: plugin
      end
      %w[
        30da81808000c2a77244f875099af35dfe0d0b7f00fefd250006f4cefee50b600021fe3e0071f4e9fe090c59002dfe4100000000000000000000000000000000
        30dd81808080bd877243e8750922f34bff9e0a1101eafdc6ffc9f2d9fec40a1101e4fdb9ff45f3aafef10aeb00fffdaeff000000000000000000000000000000
        30df81c080c0c187724708760c2df55fffed0a35014cfe4600d4f5c1ffcc0a290131fe2d00a0f49effb00a1e0115fe0f00000000000000000000000000000000
      ].each do |d|
        procon = ProconBypassMan::Procon.new([d].pack("H*"))
        procon.apply!
        procon.to_binary
      end
    end
  end

  context 'with macro' do
    context 'y, bを押しているとき' do
      let(:data) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }
      before do
        module FastReturn
          def self.name
            :fast_return
          end

          def self.steps
            [:down, :a, :a, :x, :down, :a, :a].freeze
          end
        end
        ProconBypassMan.buttons_setting_configure do
          install_macro_plugin FastReturn
          prefix_keys_for_changing_layer [:zr]
          layer :up do
            macro FastReturn, if_pressed: [:y, :b]
          end
        end
      end
      it "[:down, :a, :a, :x, :down, :a, :a]の順番で押していく" do
        procon = ProconBypassMan::Procon.new(binary)
        expect(procon.pressed_y?).to eq(true)
        expect(procon.pressed_b?).to eq(true)
        procon.apply!
        procon = ProconBypassMan::Procon.new(procon.to_binary)
        expect(procon.pressed_down?).to eq(true)

        procon = ProconBypassMan::Procon.new(procon.to_binary)
        expect(procon.pressed_down?).to eq(false)
        expect(procon.pressed_a?).to eq(true)

        procon = ProconBypassMan::Procon.new(procon.to_binary)
        expect(procon.pressed_down?).to eq(false)
        expect(procon.pressed_a?).to eq(true)

        procon = ProconBypassMan::Procon.new(procon.to_binary)
        expect(procon.pressed_down?).to eq(false)
        expect(procon.pressed_a?).to eq(false)
        expect(procon.pressed_x?).to eq(true)

        procon = ProconBypassMan::Procon.new(procon.to_binary)
        expect(procon.pressed_a?).to eq(false)
        expect(procon.pressed_x?).to eq(false)
        expect(procon.pressed_down?).to eq(true)

        procon = ProconBypassMan::Procon.new(procon.to_binary)
        expect(procon.pressed_x?).to eq(false)
        expect(procon.pressed_down?).to eq(false)
        expect(procon.pressed_a?).to eq(true)
      end
    end
  end

  context 'with remap' do
    it do
      ProconBypassMan.buttons_setting_configure do
        prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
        layer :up do
          remap :l, to: :zr
        end
      end
      no_action_binary = ["30f28100800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000"].pack("H*")
      procon = ProconBypassMan::Procon.new(no_action_binary)
      procon.user_operation.press_button(:l)
      procon.user_operation.press_button(:zr)
      procon.apply!
      b = procon.to_binary
      expect(b.unpack "H*").to eq([
        "30f28180800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000"
      ])
    end
  end

  context 'with force_neutral' do
    before do
      ProconBypassMan.buttons_setting_configure do
        prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
        layer :up do
          flip :y, if_pressed: [:y], force_neutral: [:b, :l]
        end
        layer :right
        layer :left
        layer :down
      end
    end
    context 'y, bを押しているとき' do
      let(:data) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }
      it 'bは押していない' do
        procon = ProconBypassMan::Procon.new(binary)
        expect(procon.pressed_y?).to eq(true)
        expect(procon.pressed_b?).to eq(true)
        procon.apply!
        expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_y?).to eq(true)
        expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_b?).to eq(false)

        procon = ProconBypassMan::Procon.new(binary)
        expect(procon.pressed_y?).to eq(true)
        expect(procon.pressed_b?).to eq(true)
        procon.apply!
        expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_y?).to eq(false)
        expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_b?).to eq(false)
      end
    end
  end

  context '色々詰め込んでいる' do
    before do
      class AModePlugin
        def self.name; :foo; end
        def self.binaries; ['a']; end
      end
      ProconBypassMan.buttons_setting_configure do
        install_mode_plugin AModePlugin
        prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
        layer :up do
          flip :down, if_pressed: true
          flip :zr, if_pressed: true
          flip :a
          flip :zl, if_pressed: [:y, :b]
        end
        layer :right, mode: AModePlugin
        layer :left do
        end
        layer :down do
          flip :zl, if_pressed: true
        end
      end
    end

    describe 'change_layer?' do
      context 'zr, r, zl, l, :rightを押しているとき' do
        let(:data) { "306991c080c4c987734758740af2011c03ef0f5bffe2ffedffe8013403e00f70fff0fff4ffe8014a03cb0f6effeefff2ff000000000000000000000000000000" }
        it 'ニュートラルになる' do
          procon = ProconBypassMan::Procon.new(binary)
          expect(procon.current_layer_key).to eq(:up)
          expect(procon.current_layer.mode).to eq(:manual)
          b = ProconBypassMan::Domains::ProcessingProconBinary.new(binary: binary)
          ProconBypassMan::Procon::LayerChanger.new(binary: b).tap do |layer_changer|
            expect(layer_changer.change_layer?).to eq(true)
            expect(layer_changer.next_layer_key).to eq(:right)
          end
          procon.apply! # change layer

          expect(procon.current_layer_key).to eq(:right)
          expect(procon.current_layer.mode).to eq(:AModePlugin)
          expect(procon.pressed_a?).to eq(false)
          expect(procon.pressed_b?).to eq(false)
          expect(procon.pressed_y?).to eq(false)
          expect(procon.pressed_x?).to eq(false)
          expect(procon.pressed_l?).to eq(false)
          expect(procon.pressed_right?).to eq(false)

          procon = ProconBypassMan::Procon.new(binary)
          procon.user_operation.press_button(:up)
          procon.apply! # change layer
          expect(procon.current_layer_key).to eq(:up)
          expect(procon.current_layer.mode).to eq(:manual)
          ProconBypassMan::Procon::LayerChanger.new(binary: procon.user_operation.binary).tap do |layer_changer|
            expect(layer_changer.change_layer?).to eq(false)
          end

          # zrを押す
          pressed_zr_data = "3012818a8000b0377246f8750988f5c70bfb011400e9ff180083f5d00bf9011100ecff190088f5d10bf9011000f1ff1c00000000000000000000000000000000"
          pressed_zr_binary = [pressed_zr_data].pack("H*")
          procon = ProconBypassMan::Procon.new(pressed_zr_binary)
          procon.apply!
          procon.to_binary
          expect(procon.pressed_zr?).to eq(true)

          procon = ProconBypassMan::Procon.new(pressed_zr_binary)
          procon.apply!
          procon.to_binary
          expect(procon.pressed_zr?).to eq(false)

          procon = ProconBypassMan::Procon.new(pressed_zr_binary)
          procon.apply!
          procon.to_binary
          expect(procon.pressed_zr?).to eq(true)

          # change layer
          procon = ProconBypassMan::Procon.new(binary)
          procon.user_operation.press_button(:down)
          procon.user_operation.unpress_button(:right)
          procon.apply! # change layer
          expect(procon.current_layer_key).to eq(:down)
          expect(procon.current_layer.mode).to eq(:manual)
          ProconBypassMan::Procon::LayerChanger.new(binary: procon.user_operation.binary).tap do |layer_changer|
            expect(layer_changer.change_layer?).to eq(false)
          end

          procon = ProconBypassMan::Procon.new(pressed_zr_binary)
          procon.user_operation.press_button(:zl)
          procon.apply!
          procon.to_binary
          expect(procon.current_layer_key).to eq(:down)
          expect(procon.pressed_zl?).to eq(true)

          procon = ProconBypassMan::Procon.new(pressed_zr_binary)
          procon.user_operation.press_button(:zl)
          procon.apply!
          procon.to_binary
          expect(procon.current_layer_key).to eq(:down)
          expect(procon.pressed_zl?).to eq(false)
        end
      end
    end

    describe '#pressed_zr?' do
      subject { ProconBypassMan::Procon.new(binary).pressed_zr? }
      context 'zr押している' do
        let(:data) { "3012818a8000b0377246f8750988f5c70bfb011400e9ff180083f5d00bf9011100ecff190088f5d10bf9011000f1ff1c00000000000000000000000000000000" }
        it { expect(subject).to eq(true) }
      end
      context 'zr押していない' do
        let(:data) { "30f28100800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000" }
        it { expect(subject).to eq(false) }
      end
    end

    describe '#pressed_down?' do
      subject { ProconBypassMan::Procon.new(binary).pressed_down? }
      context 'zr押していない' do
        let(:data) { "30f28100800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000" }
        it { expect(subject).to eq(false) }
      end
      context 'zr押している' do
        let(:data) { "3012818a8000b0377246f8750988f5c70bfb011400e9ff180083f5d00bf9011100ecff190088f5d10bf9011000f1ff1c00000000000000000000000000000000" }
        it { expect(subject).to eq(false) }
      end
    end

    describe 'ZRを押しっぱなしのときは出力をトグルすること' do
      context 'zr押している' do
        let(:data) { "3012818a8000b0377246f8750988f5c70bfb011400e9ff180083f5d00bf9011100ecff190088f5d10bf9011000f1ff1c00000000000000000000000000000000".freeze }
        it do
          procon = ProconBypassMan::Procon.new(binary)
          procon.apply!
          expect(procon.pressed_zr?).to eq(true)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_zr?).to eq(true)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_down?).to eq(false)

          procon = ProconBypassMan::Procon.new(binary)
          procon.apply!
          expect(procon.pressed_zr?).to eq(true)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_zr?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_down?).to eq(false)

          procon = ProconBypassMan::Procon.new(binary)
          procon.apply!
          expect(procon.pressed_zr?).to eq(true)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_zr?).to eq(true)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_down?).to eq(false)
        end
      end
      context 'a, zr押していない' do
        let(:data) { "30f28100800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000" }
        it do
          procon = ProconBypassMan::Procon.new(binary)
          procon.apply!
          expect(procon.pressed_zr?).to eq(false)
          expect(procon.pressed_a?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_zr?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_down?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_a?).to eq(true)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_zl?).to eq(false)

          procon = ProconBypassMan::Procon.new(binary)
          procon.apply!
          expect(procon.pressed_zr?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_zr?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_down?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_a?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_zl?).to eq(false)

          procon = ProconBypassMan::Procon.new(binary)
          procon.apply!
          expect(procon.pressed_zr?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_zr?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_down?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_a?).to eq(true)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_zl?).to eq(false)
        end
      end
      context 'y, b押している' do
        it do
          # TODO
        end
      end
      context 'zr押していない' do
        let(:data) { "30f28100800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000" }
        it do
          procon = ProconBypassMan::Procon.new(binary)
          procon.apply!
          expect(procon.pressed_zr?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_zr?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_down?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_zl?).to eq(false)

          procon = ProconBypassMan::Procon.new(binary)
          procon.apply!
          expect(procon.pressed_zr?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_zr?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_down?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_zl?).to eq(false)

          procon = ProconBypassMan::Procon.new(binary)
          procon.apply!
          expect(procon.pressed_zr?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_zr?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_down?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pressed_zl?).to eq(false)
        end
      end
    end
  end
end
