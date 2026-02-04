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
      "zima_creds"
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

        transmission.path = "/transmission";
        transmission.target = "http://127.0.0.1:${toString config.local.download.transmission.port}/transmission";

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
      mediaDir = "/srv/media";

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
      downloadDir = "/srv/downloads";

      transmission = {
        enable = true;
        subPath = "/transmission";
        openFirewall = false;
      };

      pinchflat = {
        enable = true;
        subPath = "/pinchflat";
        openFirewall = false;
      };
    };

    # File shares (optional)
    # shares = {
    #   enable = true;
    #   samba.enable = true;
    #   samba.openFirewall = true;
    # };
  };

  users.users.tod = {
    shell = pkgs.fish;
    initialPassword = "rockman";
  };

  system.stateVersion = "25.11";
}
