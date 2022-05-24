module ProconBypassMan::ProconDisplay
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
    end
  end
end
