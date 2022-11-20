require 'benchmark/ips'
require "procon_bypass_man"
require "tempfile"

setting_content = 
  <<~EOH
    version: 1.0
    setting: |-
      prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
      layer :up do
        flip :zr, if_pressed: :zr
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
