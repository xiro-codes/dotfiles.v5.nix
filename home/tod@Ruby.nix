{ pkgs, inputs, lib, config,... }: {
  imports = [
    ./profiles/workstation.nix
  ];
  local.secrets.keys = [ "gemini/api_key" ];
  home.sessionVariables = {
    GEMINI_API_KEY = "$(cat ${config.sops.secrets."gemini/api_key".path})";
  };
  home.stateVersion = "25.11";
}
