{
  pkgs,
  inputs,
  ...
}:
let
in
{
  imports = [
    ../profiles/workstation
  ];
  local.wallpapers = {
    name = "deskmat-2.jpg";
  };
  home.stateVersion = "25.11";
}
