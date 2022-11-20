require "stackprof"
require "procon_bypass_man"

# no action
raw_binary = ["30f28100800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000"].pack("H*")
binary = ProconBypassMan::Domains::InboundProconBinary.new(binary: raw_binary)
StackProf.run(mode: :cpu, out: 'tmp/stackprof.dump') do
  10000.times do
    ProconBypassMan::Processor.new(binary).process
  end
end
