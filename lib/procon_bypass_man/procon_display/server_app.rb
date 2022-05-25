module ProconBypassMan::ProconDisplay
  class ServerApp
    def initialize(env)
      @env = env
    end

    def call
      case @env["PATH"]
      when "/"
        response = ProconBypassMan::ProconDisplay::Status.instance.current
        HttpResponse.new(response, status: 200).to_s
      else
        HttpResponse.new(nil, status: 404).to_s
      end
    end
  end
end
