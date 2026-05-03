{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./profiles/server
  ];
  local.secrets.keys = [ "gemini/api_key" ];

  home.stateVersion = "25.11";
}
