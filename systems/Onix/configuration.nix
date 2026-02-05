{ pkgs, config, lib, ... }: {
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../profiles/server.nix
    ../profiles/base.nix
    ../profiles/limine-uefi.nix
  ];

  local = {
    # System settings
    disks.enable = true;
    #hosts.useAvahi = true;

    secrets.keys = [
      "gemini/api_key"
      "ssh_pub_ruby/master"
      "ssh_pub_sapphire/master"
      "ssh_pub_onix/master"
      "onix_creds"
    ];
    pihole = {
      enable = true;
      adminPassword = "rockman";
    };

    # Reverse proxy with HTTPS
    reverse-proxy = {
      enable = true;
      # Domain auto-configured from Avahi: onix.local
      useACME = false; # Self-signed for .local domains
      domain = "onix.home";
      services = {
        dashboard.target = "http://127.0.0.1:${toString config.local.dashboard.port}";

        git.target = "http://127.0.0.1:${toString config.local.gitea.port}";

        tv.target = "http://127.0.0.1:${toString config.local.media.jellyfin.port}";

        ch7.target = "http://127.0.0.1:${toString config.local.media.ersatztv.port}";

        dl.target = "http://127.0.0.1:${toString config.local.download.qbittorrent.port}";

        yt.target = "http://127.0.0.1:${toString config.local.download.pinchflat.port}";
      };
    };

    # Dashboard
    dashboard = {
      enable = true;
      allowedHosts = [ config.local.reverse-proxy.domain "localhost" ];
    };

    # Git service
    gitea = { enable = true; };

    # Media services
    media = {
      enable = true;
      mediaDir = "/media/Media/";

      jellyfin = { enable = true; };

      ersatztv = { enable = true; };
    };

    # Download services
    download = {
      enable = true;
      downloadDir = "/media/Media/downloads";

      qbittorrent = { enable = true; };
      pinchflat = { enable = true; };
    };
  };

  users.users.tod = {
    shell = pkgs.fish;
    initialPassword = "rockman";
  };
  systemd.tmpfiles.rules = [
    "d /media/Media 0777 root root -"
    "d /media/Backups 0777 root root -"
  ];
  networking.firewall = {
    trustedInterfaces = [ "lo" ];
    allowedTCPPortRanges =
      [{
        from = 0;
        to = 65535;
      }];
    allowedUDPPortRanges =
      [{
        from = 0;
        to = 65535;
      }];
  };
  system.stateVersion = "25.11";
}
