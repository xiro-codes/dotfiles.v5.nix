{ pkgs, inputs, lib, config, ... }: {
  imports = [
    ./profiles/workstation.nix
  ];
  local.secrets.keys = [ "gemini/api_key" ];
  home.packages = with pkgs; [
    caligula
  ];
  home.stateVersion = "25.11";
}
