module ProconBypassMan
  class Procon
    # macroキーにメタデータを埋め込んでいる. 通常の処理では露出したくないので露出しないためのクラス
    class MacroPluginMap < ::Hash
      def [](value)
        self.fetch([value, :normal], nil)
      end

      def each(&block)
        transform_keys!(&:first)
        super
      end

      alias_method :original_keys, :keys
      def keys
        super.map(&:first)
      end

      def raw_keys
        self.original_keys
      end
    end
  end
end
