class ProconBypassMan::GC
  def self.stop_gc_in(&block)
    ::GC.disable
    block.call
    ::GC.enable
  end
end
