{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./profiles/server
  ];

  # Server-specific secrets
  local.secrets.keys = [
    "gemini/api_key"
    "gemini/crush_agent_key"
  ];

  home.stateVersion = "25.11";
}
