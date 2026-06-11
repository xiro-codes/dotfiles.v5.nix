{ lib, config, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.local.shared = mkOption {
    type = types.attrsOf types.anything;
    default = { };
    description = "A global namespace for modules to share state without depending directly on each other's specific configuration options.";
  };
}
