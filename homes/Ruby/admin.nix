{
  pkgs,
  inputs,
  ...
}:
let
in
{
  imports = [
    ../profiles/server/default.nix
  ];
  home.packages = with pkgs; [
    geminicommit
    crush
  ];
  home.stateVersion = "25.11";
}
