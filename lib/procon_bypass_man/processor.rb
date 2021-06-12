class ProconBypassMan::Processor
  @@pushed_map = {}

  # @return [String] binary
  def initialize(binary)
    @binary = binary
  end

  # @return [String] 加工後の入力データ
  def process
    unless @binary[0] == "\x30".b
      return @binary
    end

    procon = ProconBypassMan::Procon.new(@binary)
    if procon.pushed_zr?
      if @@pushed_map[:zr] = !!@@pushed_map[:zr]
        procon.unpush(:zr)
      end
      puts "ZRが押されています"
    end
    if procon.pushed_down?
      puts "downが押されています"
    end

    @binary = procon.to_binary
  end
end
