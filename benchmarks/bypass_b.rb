require 'benchmark/ips'
require "procon_bypass_man"
require "tempfile"

setting_content = 
  <<~EOH
    version: 1.0
    setting: |-
      enable(:rumble_on_layer_change)

      install_macro_plugin ProconBypassMan::Plugin::Splatoon3::Macro::FastReturn
      install_macro_plugin ProconBypassMan::Plugin::Splatoon3::Macro::JumpToUpKey
      install_macro_plugin ProconBypassMan::Plugin::Splatoon3::Macro::JumpToRightKey
      install_macro_plugin ProconBypassMan::Plugin::Splatoon3::Macro::JumpToLeftKey
      install_macro_plugin ProconBypassMan::Plugin::Splatoon3::Macro::SokuwariForSplashBomb
      install_mode_plugin ProconBypassMan::Plugin::Splatoon3::Mode::Guruguru

      install_macro_plugin ProconBypassMan::Plugin::Splatoon3::Macro::DaseiCancel

      prefix_keys_for_changing_layer [:zr, :zl, :l]
      set_neutral_position 1906, 1886

      layer :up, mode: :manual do
        flip :zr, if_pressed: :zr, force_neutral: :zl
        flip :zl, if_pressed: [:y, :b, :zl]
        flip :a, if_pressed: [:a]
        flip :down, if_pressed: :down
        macro ProconBypassMan::Plugin::Splatoon3::Macro::FastReturn, if_pressed: [:y, :b, :down]
        macro ProconBypassMan::Plugin::Splatoon3::Macro::JumpToUpKey, if_pressed: [:y, :b, :up]
        macro ProconBypassMan::Plugin::Splatoon3::Macro::JumpToRightKey, if_pressed: [:y, :b, :right]
        macro ProconBypassMan::Plugin::Splatoon3::Macro::JumpToLeftKey, if_pressed: [:y, :b, :left]

        remap :l, to: :zr
        open_macro :shake, steps: [:shake_left_stick_and_toggle_b_for_0_1sec], if_pressed: [:b, :r], force_neutral: [:b]
        left_analog_stick_cap cap: 1100, if_pressed: [:zl, :a], force_neutral: :a
        open_macro :forward_ikarole, steps: [:forward_ikarole1], if_pressed: [:thumbl], force_neutral: []
        disable_macro :all, if_pressed: :a
        disable_macro :all, if_pressed: :zr
        macro ProconBypassMan::Plugin::Splatoon3::Macro::DaseiCancel, if_tilted_left_stick:  { threshold: 700 }, if_pressed: [:zl]
      end
  EOH
setting = Tempfile.new
setting.write(setting_content)
setting.rewind
ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting.path)

Benchmark.ips do |x|
  raw_binary_of_no_action = ["30f28100800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000"].pack("H*")
  binary = ProconBypassMan::Domains::InboundProconBinary.new(binary: raw_binary_of_no_action)
  x.report("no action") do
    ProconBypassMan::Processor.new(binary).process
  end

  raw_binary_of_changing_layer = "30f281c080c078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000"
  binary = ProconBypassMan::Domains::InboundProconBinary.new(binary: raw_binary_of_changing_layer)
  x.report("changing layer") do
    ProconBypassMan::Processor.new(binary).process
  end

  raw_binary_of_pressing_zr = "30f28180800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000"
  binary = ProconBypassMan::Domains::InboundProconBinary.new(binary: raw_binary_of_pressing_zr)
  x.report("flipping") do
    ProconBypassMan::Processor.new(binary).process
  end

  # TODO: macro


  x.compare!
end
