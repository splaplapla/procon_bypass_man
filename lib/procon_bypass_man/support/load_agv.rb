module ProconBypassMan
  class LoadAgv
    PATH = '/proc/loadavg'

    # @return [[Integer, Integer, Integer]]
    def get
      loadavg = get_proc_loadavg
      loadavg =~ /^([0-9.]+)\s([0-9.]+)\s([0-9.]+)/
      return [$1.to_f, $2.to_f, $3.to_f].join("-")
    rescue Errno::ENOENT
      ""
    end

    private

    def get_proc_loadavg
      File.read('/proc/loadavg')
    end
  end
end
