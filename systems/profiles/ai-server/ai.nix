{ config, ... }:
{
  local.ai = {
    ollama.enable = true;
    webui.enable = true;
  };
}
