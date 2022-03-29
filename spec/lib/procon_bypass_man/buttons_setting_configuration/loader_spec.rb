require "spec_helper"

describe ProconBypassMan::ButtonsSettingConfiguration::Loader do
  before(:each) do
    ProconBypassMan.reset!
  end

  let(:setting) { Setting.new(setting_content).to_file }

  describe '#to_hash' do
    let(:setting_content) do
      <<~EOH
version: 1.0
setting: |
  fast_return = ProconBypassMan::Plugin::Splatoon2::Macro::FastReturn
  guruguru = ProconBypassMan::Plugin::Splatoon2::Mode::Guruguru

  install_macro_plugin fast_return
  install_macro_plugin ProconBypassMan::Plugin::Splatoon2::Macro::JumpToUpKey
  install_macro_plugin ProconBypassMan::Plugin::Splatoon2::Macro::JumpToRightKey
  install_macro_plugin ProconBypassMan::Plugin::Splatoon2::Macro::JumpToLeftKey
  install_mode_plugin guruguru

  prefix_keys_for_changing_layer [:zr, :zl, :l]
  set_neutral_position 2100, 2000

  layer :up, mode: :manual do
    # flip :zr, if_pressed: :zr, force_neutral: :zl
    flip :zr, if_pressed: :zr, force_neutral: :zl
    flip :zl, if_pressed: [:y, :b, :zl]
    flip :a, if_pressed: [:a]
    flip :down, if_pressed: :down
    # disable [:up]
    macro fast_return.name, if_pressed: [:y, :b, :down]
    macro ProconBypassMan::Plugin::Splatoon2::Macro::JumpToUpKey, if_pressed: [:y, :b, :up]
    macro ProconBypassMan::Plugin::Splatoon2::Macro::JumpToRightKey, if_pressed: [:y, :b, :right]
    macro ProconBypassMan::Plugin::Splatoon2::Macro::JumpToLeftKey, if_pressed: [:y, :b, :left]
    remap :l, to: :zr
    left_analog_stick_cap cap: 1100, if_pressed: [:zl, :a], force_neutral: :a
  end
  layer :right, mode: guruguru.name
  layer :left do
  # flip :zr, if_pressed: :zr, force_neutral: :zl
    remap :l, to: :zr
  end
  layer :down do
    # flip :zl
    # flip :zr, if_pressed: :zr, force_neutral: :zl, flip_interval: "1F"
    remap :l, to: :zr
  end
version: 1.0
name: title1
  end
      EOH
    end

    it do
      config = described_class.load(setting_path: setting.path)
      actual_layer_up = config.layers[:up].to_hash
      expect(actual_layer_up).to include(mode: :manual)
      expect(actual_layer_up).to include(:flips=>{:zr=>{:if_pressed=>[:zr], :force_neutral=>[:zl]}, :zl=>{:if_pressed=>[:y, :b, :zl]}, :a=>{:if_pressed=>[:a]}, :down=>{:if_pressed=>[:down]}})
      expect(actual_layer_up).to include(
        macros: {
          :"ProconBypassMan::Plugin::Splatoon2::Macro::FastReturn"=>{:if_pressed=>[:y, :b, :down]},
          :"ProconBypassMan::Plugin::Splatoon2::Macro::JumpToUpKey"=>{:if_pressed=>[:y, :b, :up]},
          :"ProconBypassMan::Plugin::Splatoon2::Macro::JumpToRightKey"=>{:if_pressed=>[:y, :b, :right]},
          :"ProconBypassMan::Plugin::Splatoon2::Macro::JumpToLeftKey"=>{:if_pressed=>[:y, :b, :left]}
        }
      )
      expect(actual_layer_up).to include(:remaps=>{:l=>{:to=>[:zr]}})
      expect(actual_layer_up).to include(:left_analog_stick_caps=>[{:cap=>1100, :if_pressed=>[:zl, :a], :force_neutral=>[:a]}])
    end
  end
end
