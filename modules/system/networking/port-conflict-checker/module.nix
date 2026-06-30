{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    concatStringsSep
    filterAttrs
    flatten
    foldl
    mapAttrsToList
    optional
    ;

  cfg = config.local;

  # Helper to make a port entry
  mkPort = name: port: { inherit name port; };

  # Collect all configured ports
  configuredPorts = flatten [
    (optional (cfg.dashboard.enable or false) (mkPort "Dashboard" cfg.dashboard.port))
    (optional (cfg.gitea.enable or false) (mkPort "Gitea Web" cfg.gitea.port))
    (optional (cfg.gitea.enable or false) (mkPort "Gitea SSH" (cfg.gitea.sshPort or 2222)))
    (optional (cfg.file-browser.enable or false) (mkPort "File Browser" cfg.file-browser.port))
    (optional (cfg.media.jellyfin.enable or false) (mkPort "Jellyfin" cfg.media.jellyfin.port))
    (optional (cfg.media.plex.enable or false) (mkPort "Plex" cfg.media.plex.port))
    (optional (cfg.media.ersatztv.enable or false) (mkPort "ErsatzTV" cfg.media.ersatztv.port))
    (optional (cfg.media.komga.enable or false) (mkPort "Komga" cfg.media.komga.port))
    (optional (cfg.media.audiobookshelf.enable or false) (mkPort "Audiobookshelf" cfg.media.audiobookshelf.port))
    (optional (cfg.downloads.qbittorrent.enable or false) (mkPort "Qbittorrent" cfg.downloads.qbittorrent.port))
    (optional (cfg.downloads.pinchflat.enable or false) (mkPort "Pinchflat" cfg.downloads.pinchflat.port))
    (optional (cfg.harmonia-cache.enable or false) (mkPort "Cache Server" cfg.harmonia-cache.port))
    (optional (cfg.reverse-proxy.enable or false) (mkPort "Reverse Proxy HTTP" 80))
    (optional (cfg.reverse-proxy.enable or false) (mkPort "Reverse Proxy HTTPS" 443))
  ];

  # Helper to find duplicates
  checkConflicts =
    ports:
    let
      grouped = foldl (
        acc: entry:
        let
          p = toString entry.port;
          existing = acc.${p} or [ ];
        in
        acc // { ${p} = existing ++ [ entry.name ]; }
      ) { } ports;

      conflicts = filterAttrs (port: names: (builtins.length names) > 1) grouped;

      formatConflict =
        port: names: "Port ${port} is used by multiple services: ${concatStringsSep ", " names}";
    in
    mapAttrsToList formatConflict conflicts;

  conflicts = checkConflicts configuredPorts;
in
{
  config = {
    assertions = [
      {
        assertion = conflicts == [ ];
        message = "Port conflicts detected:\n${concatStringsSep "\n" conflicts}";
      }
    ];
  };
}
