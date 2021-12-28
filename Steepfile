# D = Steep::Diagnostic
#
# target :lib do
#   signature "sig"
#
#   check "lib"                       # Directory name
#   check "Gemfile"                   # File name
#   check "app/models/**/*.rb"        # Glob
#   # ignore "lib/templates/*.rb"
#
#   # library "pathname", "set"       # Standard libraries
#   # library "strong_json"           # Gems
#
#   # configure_code_diagnostics(D::Ruby.strict)       # `strict` diagnostics setting
#   # configure_code_diagnostics(D::Ruby.lenient)      # `lenient` diagnostics setting
#   # configure_code_diagnostics do |hash|             # You can setup everything yourself
#   #   hash[D::Ruby::NoMethod] = :information
#   # end
# end

# target :test do
#   signature "sig", "sig-private"
#
#   check "test"
#
#   # library "pathname", "set"       # Standard libraries
# end

target :lib do
  check "lib/procon_bypass_man/timer.rb"
  check "lib/procon_bypass_man/uptime.rb"
  check "lib/procon_bypass_man/configuration.rb"
  check 'lib/procon_bypass_man/support/on_memory_cache'

  signature "sig"

  library "time"
  library "logger"
  library "monitor"
end
