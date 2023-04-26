class ProconBypassMan::WebConnectivityChecker
  # @param [String, NilClass] url
  # @param [String, NilClass] ws_url
  def initialize(url, ws_url)
    @url = url
    @ws_url = ws_url
  end

  # @return [String]
  def to_s
    if @url.nil?
      return "DISABLE"
    end

    if alive?
      return "ENABLE (#{@url}, #{@ws_url})"
    else
     return "UNREACHABLE (#{@url})"
    end
  end

  private

  # @return [Boolean]
  def alive?
    uri = URI.parse(@url)
    response = nil

    begin
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        request = Net::HTTP::Head.new(uri)
        response = http.request(request)
      end
    rescue StandardError => e
      ProconBypassMan.logger.error e
      return false
    end

    response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPMovedPermanently)
  end
end
