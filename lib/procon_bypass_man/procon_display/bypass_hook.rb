module ProconBypassMan::ProconDisplay::BypassHook
  include ProconBypassMan::Callbacks

  define_callbacks :run

  set_callback :run, :after, :write_procon_display_status

  def write_procon_display_status
    return unless bypass_value.binary
    ProconBypassMan::ProconDisplay::Status.instance.current = bypass_value.binary.to_procon_reader.to_hash.dup
  end
end
