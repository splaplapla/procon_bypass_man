class ProconBypassMan::GC
  def self.stop_gc_in(&block)
    ::GC.disable
    result = block.call
    ::GC.enable
    return result
  end
end
