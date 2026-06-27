{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ../profiles/server
  ];
  systemd.user.enable = true;

  local.nixvim.enable = true;

  home.stateVersion = "25.11";
}
