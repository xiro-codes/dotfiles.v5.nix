{ inputs, pkgs, ... }:
{
  imports = [
    ./profiles/server
  ];

  # Server-specific secrets
  local.secrets.keys = [ "gemini/api_key" ];

  home.stateVersion = "25.11";
}
