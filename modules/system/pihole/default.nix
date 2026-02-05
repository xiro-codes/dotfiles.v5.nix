{ config, lib, pkgs, ... }:
let
  cfg = config.local.pihole;
in
{
  options.local.pihole = {
    enable = lib.mkEnableOption "Pi-hole DNS service";
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/pihole";
      description = "Directory to store Pi-hole configuration and data.";
    };
    adminPassword = lib.mkOption {
      type = lib.types.str;
      default = "admin";
      description = "Admin password for the Pi-hole Web UI.";
    };
  };
  config = lib.mkIf cfg.enable {
    # Ensure the data directories exist
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 root root -"
      "d ${cfg.dataDir}/dnsmasq.d 0755 root root -"
    ];

    virtualisation.oci-containers.containers.pihole = {
      image = "pihole/pihole:latest";
      ports = [
        "53:53/tcp"
        "53:53/udp"
        "8053:80/tcp" # Web UI port (shifted to avoid Nginx 80)
      ];
      volumes = [
        "${cfg.dataDir}:/etc/pihole"
        "${cfg.dataDir}/dnsmasq.d:/etc/dnsmasq.d"
      ];
      environment = {
        TZ = config.time.timeZone or "UTC";
        WEBPASSWORD = cfg.adminPassword;
        # Crucial for Nginx proxying later
      };
      autoStart = true;
    };

    # Open firewall for DNS traffic
    networking.firewall = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };

    # Disable systemd-resolved from grabbing port 53
    #services.resolved.enable = false;
    services.resolved.settings.DNSStubListener = "no";
    #services.resolved.extraConfig = ''
    #  DNSStubListener=no
    #'';
  };
}
