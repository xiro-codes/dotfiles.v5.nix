{
  config,
  lib,
  ...
}:
let
  inherit (lib.strings) toLower;
in
{
  local.reverse-proxy = {
    enable = true;
    useACME = false;
    domain = "${toLower config.networking.hostName}.home";
    services = {
      ui.target = "http://localhost:${toString config.local.ai.webui.port}";
      ai.target = "http://localhost:${toString config.local.ai.ollama.port}";
    };
  };
}
