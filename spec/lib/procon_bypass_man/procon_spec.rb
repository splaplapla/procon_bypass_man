require "spec_helper"

describe ProconBypassMan::Procon do
  let(:binary) { [data].pack("H*") }

  before(:each) do
    ProconBypassMan.reset!
  end

  context 'with mode' do
    let(:data) { "30f28100800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000" } # no_action
    let(:pressed_y_and_b) { "30778105800099277344e86b0a7909f4f5a8f4b500c5ff8dff6c09cdf5b8f49a00c5ff92ff6a0979f5eef46500d5ff9bff000000000000000000000000000000" }
    let(:not_pressed_y_and_b) { "30f28100800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000" }
    it 'modeのbinariesを繰り返すこと' do
      plugin = OpenStruct.new(name: :hoge, binaries: [ pressed_y_and_b, not_pressed_y_and_b ])
      ProconBypassMan.configure do
        install_mode_plugin(plugin)
        prefix_keys_for_changing_layer [:zr]
        layer :up, mode: plugin.name
      end
      procon = ProconBypassMan::Procon.new(binary)
      procon.apply!
      expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_y?).to eq(true)
      expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_b?).to eq(true)

      procon = ProconBypassMan::Procon.new(binary)
      procon.apply!
      procon.to_binary
      expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_y?).to eq(false)
      expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_b?).to eq(false)

      procon = ProconBypassMan::Procon.new(binary)
      procon.apply!
      procon.to_binary
      expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_y?).to eq(true)
      expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_b?).to eq(true)
    end
    it "can't modify frozen Stringが起きないこと" do
      plugin = OpenStruct.new(name: :hoge, binaries: [ pressed_y_and_b, not_pressed_y_and_b ])
      ProconBypassMan.configure do
        install_mode_plugin(plugin)
        prefix_keys_for_changing_layer [:zr]
        layer :up do
          flip :down, if_pushed: :down
        end
        layer :right, mode: plugin.name
      end
      %w[
        305b818480008cdcac4b28740924f79cfe410d14001c00310020f79cfe400d16001e0032001ff79cfe450d1a0020003500000000000000000000000000000000
        305d818480008d7cac4928740919f79cfe3d0d100014002c001bf79dfe3f0d0f0014002d001ef79cfe400d110019003000000000000000000000000000000000
        3061818480008b1cad49f8730915f794fe380d09001500240016f796fe370d09001200230018f797fe370d0a0010002600000000000000000000000000000000
        3063818480008cdcac4928740911f78cfe400d0d001800200012f78efe3b0d0b001800200012f793fe360d0a0017002100000000000000000000000000000000
        3066818480008cccac4908740a09f790fe3d0d15002800280009f78afe400d1200220024000af78bfe410d10001d002200000000000000000000000000000000
        3069818480008bccac4918740a01f795fe310d0c0041003000fff693fe2e0d0f003b002d0001f78dfe310d120032002b00000000000000000000000000000000
        306b818480008accac4808740a03f790fe2a0d06004900320000f78ffe2e0d0b0042002f0001f795fe310d0c0041003000000000000000000000000000000000
        306f8184800088ecac4a08740a04f797fe2d0df7ff4b00360000f793fe250dfaff4c00350004f790fe280dfdff4d003400000000000000000000000000000000
        307281848000840cad4af8730a01f7b0fe3f0df2ff43003b0001f7a9fe3c0df5ff49003c0000f7a4fe380df4ff48003900000000000000000000000000000000
        3074818480006d2cb04928740a04f7c1fe640decff3400390005f7c1fe5b0dedff36003a0002f7bdfe4b0deeff3a003b00000000000000000000000000000000
        30778184800066dcb44718740a07f7a6fe860df3ff1b00350008f7acfe7c0df1ff1d00350008f7b5fe730df1ff24003700000000000000000000000000000000
        307a81848000667cb54718740a14f785fe960dfeff0400330011f790fe940dfdff080035000df798fe930df8ff10003300000000000000000000000000000000
        307d81848000563cb74918740ae8f664fec50d0800ddff3400e9f66efeb80d0800e4ff3200f9f676fead0d0700f3ff3300000000000000000000000000000000
        3080818080004a6cb84b28740ad5f65afe300e0600a0ff2a00d0f657fe0a0e0800b4ff2c00d3f658feea0d0800ceff3200000000000000000000000000000000
        30848180800007acbb4a18740a39f744fe950e090029ff29002bf741fea30e080035ff270004f756fe8b0e050061ff2600000000000000000000000000000000
        30898180800099ebc04518740abef675fee20e030060fe12008ef67cfe4f0f2500a9fe2a00fef64ffe240f4100cbfe2e00000000000000000000000000000000
        308b818080007d2bc34718740a9cf76afe050e18002bfe0e0065f764fe290e18002dfe100028f762fe600e000037fe0900000000000000000000000000000000
        308e818080000aabc74a28740a70f794fe940d6d008cfe350082f782fea20d650063fe3400b2f77efebe0d58004dfe2e00000000000000000000000000000000
        3092810080006a0ac84a18740a21f7c4feec0c790005ff380041f7b8fe130d7700f2fe37006bf7aafe5e0d6d00befe3500000000000000000000000000000000
        309481008000335ac84a18740a29f791fed80c890040ff3000cef6b6fe870c820030ff3400f8f6cbfec10c7b0014ff3800000000000000000000000000000000
        309781008000b3d9c9491874092cf77dff110d4c00d0fe1d001af764ff520d5700e4fe1c0055f7f3fe790d7e0033ff1a00000000000000000000000000000000
        309a810080005eb9ca49087409e1f889ff380c5c00b4fe1900abf87aff560c5a00acfe180022f862ff7d0c4e009bfe1b00000000000000000000000000000000
        309d8100800017d9ca4918740968f9d1ff050c6900f0fe2c003ef9c8ff040c6900eefe2a0010f9a6ff140c5b00d1fe1800000000000000000000000000000000
        30a081008000a588c94918740971f869ff250cc400c5ff80007ef891ff360cc50071ff860003f9b4fffd0baa0048ff6e00000000000000000000000000000000
        30a38100800094f8bb48187409fdf7c6fd720bed0086005d001cf809fe710be40079005c0033f865fe8d0bc90028006200000000000000000000000000000000
        30a5810080009028af49087409ccf708fd310c3801f3006c00b8f7fcfc140c3101d4006c00d4f762fdbf0b1f01c0006800000000000000000000000000000000
        30a9810080009918944a28740960f75bfead0b75005a02b5ffd9f754fe860cc600c0011700f0f71cfe950c180169015500000000000000000000000000000000
        30ac810080004cb87b49087409f4f88efee40aeb00c0034100f0f730fee109dc006c03e8ff8bf721fef509ca004f03d1ff000000000000000000000000000000
        30ae81008000fa77744a28720971f654ff710d380188037c008ef73aff780d2901a40385007ef9fffee70c0101ff039e00000000000000000000000000000000
        30b181008000e0377245287109acf2a2ff000de6000e0368018ef368ffea0df40017034e013af46bffe80d1c0132030201000000000000000000000000000000
        30b381008000e07772491871096cf491006e0a2f005704360219f37900990a3d0011042c025bf23f002d0baa002503bb01000000000000000000000000000000
        30b781008000cd877248b870092ffbc4fe470b8500ac06a50116fa68ffee0a3f002b060b02e9f8ecffa40a2c0008062502000000000000000000000000000000
        30ba81008000c3d77249587009e8f8cdffc50b44009007dd0069f9b7ff9c0b55005e07e10056fa4dff6b0b86001407fc00000000000000000000000000000000
        30bd81008000bfd77249387009c0f5e8fedd0c900005095c014af6e5fea40c8500f0084d0142f71bff690c61008a081401000000000000000000000000000000
        30c081008000bc177247487009fcf23cffe80d8100d9089901d1f321ff970d8400e30894010ef5f1fe230d8e0006097a01000000000000000000000000000000
        30c381008000bfa7724748700959ee80fe790fd9fff0066101f0ee9efe5a0fd7ffee06610162f0fbfe020f1300e3078c01000000000000000000000000000000
        30c681008000bb2772440875090cf234ffb40e75ffcdff990047f008ff7e0f7fff1501a400ffedb2fef70f8fffaf03dc00000000000000000000000000000000
        30ca81008000bf677245b87509bcf4f0ff300c44ff0c005c0026f5f5fffc0b45ffeeff6d00baf5cbffd80b4bff99ff9000000000000000000000000000000000
        30ce81008000bc677249e8750901f5ecfeac0c5dff70ff4d00e2f4d9feb00c51ff91ff480096f40fffa30c46ffd2ff4600000000000000000000000000000000
        30d181008000bb477245d875098bf46dff8e0cd5fffafe57009cf43cff9d0cb9ff0cff5d00a3f42affa30cadff15ff5c00000000000000000000000000000000
        30d481008000be477241e875093bf4e8ff6b0c1600adfe5f0054f40200870c0e00d0fe57006cf4edff8c0cfcffe8fe5500000000000000000000000000000000
        30d681008000bf67724408760917f440ff130c2b0065fe620029f484ff290c1d0084fe65002af4abff400c1d0084fe6300000000000000000000000000000000
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
        ProconBypassMan.configure do
          prefix_keys_for_changing_layer [:zr]
          layer :up do
            macro :fast_return, if_pushed: [:y, :b]
          end
        end
      end
      it "[:down, :a, :a, :x, :down, :a, :a]の順番で押していく" do
        procon = ProconBypassMan::Procon.new(binary)
        expect(procon.pushed_y?).to eq(true)
        expect(procon.pushed_b?).to eq(true)
        procon.apply!
        procon = ProconBypassMan::Procon.new(procon.to_binary)
        expect(procon.pushed_down?).to eq(true)

        procon = ProconBypassMan::Procon.new(procon.to_binary)
        expect(procon.pushed_down?).to eq(false)
        expect(procon.pushed_a?).to eq(true)

        procon = ProconBypassMan::Procon.new(procon.to_binary)
        expect(procon.pushed_down?).to eq(false)
        expect(procon.pushed_a?).to eq(true)

        procon = ProconBypassMan::Procon.new(procon.to_binary)
        expect(procon.pushed_down?).to eq(false)
        expect(procon.pushed_a?).to eq(false)
        expect(procon.pushed_x?).to eq(true)

        procon = ProconBypassMan::Procon.new(procon.to_binary)
        expect(procon.pushed_a?).to eq(false)
        expect(procon.pushed_x?).to eq(false)
        expect(procon.pushed_down?).to eq(true)

        procon = ProconBypassMan::Procon.new(procon.to_binary)
        expect(procon.pushed_x?).to eq(false)
        expect(procon.pushed_down?).to eq(false)
        expect(procon.pushed_a?).to eq(true)
      end
    end
  end

  context 'with force_neutral' do
    before do
      ProconBypassMan.configure do
        prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
        layer :up do
          flip :y, if_pushed: [:y], force_neutral: :b
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
        expect(procon.pushed_y?).to eq(true)
        expect(procon.pushed_b?).to eq(true)
        procon.apply!
        expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_y?).to eq(true)
        expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_b?).to eq(false)

        procon = ProconBypassMan::Procon.new(binary)
        expect(procon.pushed_y?).to eq(true)
        expect(procon.pushed_b?).to eq(true)
        procon.apply!
        expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_y?).to eq(false)
        expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_b?).to eq(false)
      end
    end
  end

  context '色々詰め込んでいる' do
    before do
      ProconBypassMan.configure do
        prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
        layer :up do
          flip :down, if_pushed: true
          flip :zr, if_pushed: true
          flip :a
          flip :zl, if_pushed: [:y, :b]
        end
        layer :right, mode: :auto
        layer :left do
        end
        layer :down do
          flip :zl, if_pushed: true
        end
      end
    end

    describe '#pushed_zr?' do
      subject { ProconBypassMan::Procon.new(binary).pushed_zr? }
      context 'zr押している' do
        let(:data) { "3012818a8000b0377246f8750988f5c70bfb011400e9ff180083f5d00bf9011100ecff190088f5d10bf9011000f1ff1c00000000000000000000000000000000" }
        it { expect(subject).to eq(true) }
      end
      context 'zr押していない' do
        let(:data) { "30f28100800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000" }
        it { expect(subject).to eq(false) }
      end
    end

    describe '#pushed_down?' do
      subject { ProconBypassMan::Procon.new(binary).pushed_down? }
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
          expect(procon.pushed_zr?).to eq(true)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_zr?).to eq(true)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_down?).to eq(false)

          procon = ProconBypassMan::Procon.new(binary)
          procon.apply!
          expect(procon.pushed_zr?).to eq(true)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_zr?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_down?).to eq(false)

          procon = ProconBypassMan::Procon.new(binary)
          procon.apply!
          expect(procon.pushed_zr?).to eq(true)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_zr?).to eq(true)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_down?).to eq(false)
        end
      end
      context 'a, zr押していない' do
        let(:data) { "30f28100800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000" }
        it do
          procon = ProconBypassMan::Procon.new(binary)
          procon.apply!
          expect(procon.pushed_zr?).to eq(false)
          expect(procon.pushed_a?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_zr?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_down?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_a?).to eq(true)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_zl?).to eq(false)

          procon = ProconBypassMan::Procon.new(binary)
          procon.apply!
          expect(procon.pushed_zr?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_zr?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_down?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_a?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_zl?).to eq(false)

          procon = ProconBypassMan::Procon.new(binary)
          procon.apply!
          expect(procon.pushed_zr?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_zr?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_down?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_a?).to eq(true)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_zl?).to eq(false)
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
          expect(procon.pushed_zr?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_zr?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_down?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_zl?).to eq(false)

          procon = ProconBypassMan::Procon.new(binary)
          procon.apply!
          expect(procon.pushed_zr?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_zr?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_down?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_zl?).to eq(false)

          procon = ProconBypassMan::Procon.new(binary)
          procon.apply!
          expect(procon.pushed_zr?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_zr?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_down?).to eq(false)
          expect(ProconBypassMan::Procon.new(procon.to_binary).pushed_zl?).to eq(false)
        end
      end
    end
  end
end
