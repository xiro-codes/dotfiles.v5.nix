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
    hosts.useAvahi = true;

    secrets.keys = [
      "gemini/api_key"
      "ssh_pub_ruby/master"
      "ssh_pub_sapphire/master"
      "ssh_pub_onix/master"
      "onix_creds"
    ];

    # Reverse proxy with HTTPS
    reverse-proxy = {
      enable = true;
      # Domain auto-configured from Avahi: onix.local
      useACME = false; # Self-signed for .local domains
      domain = "onix.local";
      services = {
        dashboard.path = "/";
        dashboard.target = "http://127.0.0.1:${toString config.local.dashboard.port}";

        gitea.path = "/gitea";
        gitea.target = "http://127.0.0.1:${toString config.local.gitea.port}/";

        jellyfin.path = "/jellyfin";
        jellyfin.target = "http://127.0.0.1:${toString config.local.media.jellyfin.port}/jellyfin";

        ersatztv.path = "/ersatztv";
        ersatztv.target = "http://127.0.0.1:${toString config.local.media.ersatztv.port}/ersatztv";

        qbittorrent.path = "/qbittorrent";
        qbittorrent.target = "http://127.0.0.1:${toString config.local.download.qbittorrent.port}/";
        qbittorrent.extraConfig = ''
          sub_filter_once off;
          sub_filter '<head>' '<head>\n<base href="/qbittorrent/">';      

          # 2. Replaces absolute paths with proxied paths
          # e.g. src="/css/..." becomes src="/qbittorrent/css/..."
          sub_filter 'href="/' 'href="/qbittorrent/';
          sub_filter 'src="/'  'src="/qbittorrent/';
          sub_filter 'action="/' 'action="/qbittorrent/';
      
          # 3. Fixes JavaScript redirects if they exist
          sub_filter "window.location.href = '/" "window.location.href = '/qbittorrent/";
          proxy_set_header Accept-Encoding "";
        '';
        pinchflat.path = "/pinchflat";
        pinchflat.target = "http://127.0.0.1:${toString config.local.download.pinchflat.port}/";
        pinchflat.extraConfig = ''
          sub_filter_once off;
          sub_filter_types text/html text/javascript application/javascript;
          sub_filter 'href="/' 'href="/pinchflat/';
          sub_filter 'src="/' 'src="/pinchflat/';
          sub_filter 'data-socket-path="/' 'data-socket-path="/pinchflat/';
          sub_filter 'action="/' 'action="/pinchflat/';
        '';
      };
    };
    # Dashboard
    dashboard = {
      enable = true;
      subPath = "/";
      openFirewall = false;
    };

    # Git service
    gitea = {
      enable = true;
      subPath = "/gitea";
      openFirewall = false;
    };

    # Media services
    media = {
      enable = true;
      mediaDir = "/media/Media/";

      jellyfin = {
        enable = true;
        subPath = "/jellyfin";
        openFirewall = false;
      };

      ersatztv = {
        enable = true;
        subPath = "/ersatztv";
        openFirewall = false;
      };
    };

    # Download services
    download = {
      enable = true;
      downloadDir = "/media/Media/downloads";

      qbittorrent = {
        enable = true;
        subPath = "/qbittorrent";
        openFirewall = true;
      };
      pinchflat = {
        enable = true;
        subPath = "/pinchflat";
        openFirewall = false;
      };
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
  networking.firewall.trustedInterfaces = [ "lo" ];
  system.stateVersion = "25.11";
}
