{ inputs, pkgs, ... }:
{
  imports = [
    ./profiles/server
  ];
  systemd.user.enable = true;

  local.secrets.keys = [ "gemini/api_key" ];
  local.nixvim.enable = true;

  home.stateVersion = "25.11";
}
