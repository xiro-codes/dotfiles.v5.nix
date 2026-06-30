{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.local.backup = mkOption {
    type = types.bool;
    default = true;
    description = "Include this user's data in the host's automatic backups";
  };
}
