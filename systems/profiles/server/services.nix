{
  config,
  inputs,
  self,
  pkgs,
  ...
}:
{
  local = {
    # Dashboard
    dashboard = {
      enable = true;
      allowedHosts = [
        config.local.reverse-proxy.domain
        "localhost"
      ];
    };
    harmonia-cache = {
      enable = true;
      signKeyPaths = [ config.sops.secrets."harmonia_key".path ];
      openFirewall = true;
      prefetch.enable = true;
    };
    # Git service
    gitea = {
      enable = true;
      openFirewall = true;
    };
    minecraft-server = {
      enable = true;
      bootDelay = "5m";
      eula = true;
      openFirewall = true;
      declarative = true;
      jvmOpts = "-Xms6G -Xmx6G";
      package = self.packages.${pkgs.system}.tekkit-server;
      serverProperties = {
        server-port = 25565;
        difficulty = 1;
        gamemode = 0;
        max-players = 10;
        motd = "Tekkit Server on Onix";
      };
    };
    recovery-builder.enable = true;
  };
}
