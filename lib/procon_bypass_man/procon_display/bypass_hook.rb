module ProconBypassMan::ProconDisplay::BypassHook
  include ProconBypassMan::Callbacks

  define_callbacks :log_procon_to_gadget

  set_callback :log_procon_to_gadget, :after, :write_procon_display_Status

  def write_procon_display_Status
    ProconBypassMan::ProconDisplay::Status.instance.current = bypass_value.binary.to_procon_reader.to_hash.dup
  end
end
