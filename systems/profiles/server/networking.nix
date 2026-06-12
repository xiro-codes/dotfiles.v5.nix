{
  config,
  lib,
  ...
}:
let
  inherit (lib) toLower;
in
{
  local = {
    # Reverse proxy with HTTPS
    reverse-proxy = {
      enable = true;
      # Domain auto-configured from Avahi: hostname.local
      useACME = false; # Self-signed for .local domains
      domain = "${toLower config.networking.hostName}.home";
      sharedFolders = {
        wallpapers = "/media/Media/wallpapers";
        games = "/media/Media/games";
      };

      services = {
        dashboard.target = "http://localhost:${toString config.local.dashboard.port}";

        git.target = "http://localhost:${toString config.local.gitea.port}";

        cache.target = "http://localhost:5000";
      };
    };
  };
}
