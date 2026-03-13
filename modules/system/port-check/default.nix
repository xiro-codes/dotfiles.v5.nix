{ config, lib, ... }:

let
  inherit (lib) concatStringsSep filterAttrs flatten foldl mapAttrsToList optional;

  cfg = config.local;

  # Helper to make a port entry
  mkPort = name: port: { inherit name port; };

  # Collect all configured ports
  configuredPorts = flatten [
    (optional (cfg.dashboard.enable or false) (mkPort "Dashboard" (cfg.dashboard.port or 3000)))
    (optional (cfg.docs.enable or false) (mkPort "Docs" (cfg.docs.port or 3088)))
    (optional (cfg.gitea.enable or false) (mkPort "Gitea Web" (cfg.gitea.port or 3001)))
    (optional (cfg.gitea.enable or false) (mkPort "Gitea SSH" (cfg.gitea.sshPort or 2222)))
    (optional (cfg.file-browser.enable or false) (mkPort "File Browser" (cfg.file-browser.port or 8999)))
    (optional (cfg.media.jellyfin.enable or false) (mkPort "Jellyfin" (cfg.media.jellyfin.port or 8096)))
    (optional (cfg.media.plex.enable or false) (mkPort "Plex" (cfg.media.plex.port or 32400)))
    (optional (cfg.media.ersatztv.enable or false) (mkPort "ErsatzTV" (cfg.media.ersatztv.port or 8409)))
    (optional (cfg.media.komga.enable or false) (mkPort "Komga" (cfg.media.komga.port or 8092)))
    (optional (cfg.media.audiobookshelf.enable or false) (mkPort "Audiobookshelf" (cfg.media.audiobookshelf.port or 13378)))
    (optional (cfg.downloads.qbittorrent.enable or false) (mkPort "Qbittorrent" (cfg.downloads.qbittorrent.port or 8080)))
    (optional (cfg.downloads.pinchflat.enable or false) (mkPort "Pinchflat" (cfg.downloads.pinchflat.port or 8945)))
    (optional (cfg.cache-server.enable or false) (mkPort "Cache Server" (cfg.cache-server.port or 8080)))
    (optional (cfg.pihole.enable or false) (mkPort "PiHole DNS" 53))
    (optional (cfg.pihole.enable or false) (mkPort "PiHole Web" 8053))
    (optional (cfg.reverse-proxy.enable or false) (mkPort "Reverse Proxy HTTP" 80))
    (optional (cfg.reverse-proxy.enable or false) (mkPort "Reverse Proxy HTTPS" 443))
  ];

  # Helper to find duplicates
  checkConflicts = ports:
    let
      grouped = foldl (acc: entry:
        let
          p = toString entry.port;
          existing = acc.${p} or [];
        in
        acc // { ${p} = existing ++ [ entry.name ]; }
      ) {} ports;
      
      conflicts = filterAttrs (port: names: (builtins.length names) > 1) grouped;
      
      formatConflict = port: names:
        "Port ${port} is used by multiple services: ${concatStringsSep ", " names}";
    in
    mapAttrsToList formatConflict conflicts;

  conflicts = checkConflicts configuredPorts;
in
{
  config = {
    assertions = [
      {
        assertion = conflicts == [];
        message = "Port conflicts detected:\n${concatStringsSep "\n" conflicts}";
      }
    ];
  };
}
