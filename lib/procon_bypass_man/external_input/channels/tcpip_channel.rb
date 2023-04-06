module ProconBypassMan
  module ExternalInput
    module Channels
      class TCPIPChannel < Base
        def initialize(port: )
          super()
          # TODO: ここでTCPサーバを起動する. masterプロセスをサーバとして、bypassプロセスはクライアントとして振る舞う
        end

        def read
          # TODO: masterプロセスへ繋ぐ
        end
      end
    end
  end
end
