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
  home.stateVersion = "25.11";
}
