module ProconBypassMan::ProconDisplay
  # NOTE Support GET only
  class HttpRequest
    def self.parse(conn)
      headers = {}
      loop do
        line = conn.gets("\n")&.strip
        break if line.nil? || line.strip.empty?
        key, value = line.split(/:\s/, 2)
        headers[key] = value
      end

      new(headers)
    end

    def initialize(headers)
      @headers = headers
    end

    def path
      request_method_and_path = @headers.detect { |key, _value| key.start_with?("GET") }.first
      if request_method_and_path =~ /(?:GET) ([^ ]+)/ && (path = $1)
        return path
      end
    end

    def to_hash
      { "PATH" => path }
    end
  end
end
