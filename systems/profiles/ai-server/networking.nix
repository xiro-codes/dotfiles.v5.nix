{ config, lib, ... }:
{
  local.reverse-proxy = {
    enable = true;
    useACME = false;
    domain = "${lib.strings.toLower config.networking.hostName}.home";
    services = {
      ui.target = "http://localhost:${toString config.local.ai.webui.port}";
      ai.target = "http://localhost:${toString config.local.ai.ollama.port}";
    };
  };
}
