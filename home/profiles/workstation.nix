# Workstation home profile - Complete desktop workstation setup
{ ... }:
{
  imports = [
    ./base.nix
    ./desktop.nix
  ];
  
  # Workstation-specific secrets
  local.secrets.keys = [ "gemini/api_key" ];
}
