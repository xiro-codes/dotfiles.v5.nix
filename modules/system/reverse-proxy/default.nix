{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    literalExpression
    mapAttrs
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.local.reverse-proxy;
  onixCert =
    pkgs.runCommand "onix-local-cert"
      {
        buildInputs = [ pkgs.openssl ];
      }
      ''
        mkdir -p $out
        openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
          -keyout $out/onix.key -out $out/onix.crt \
          -subj "/CN=${cfg.domain}" \
          -addext "subjectAltName=DNS:onix.local,DNS:*${cfg.domain}" \
          -addext "basicConstraints=CA:FALSE"
      '';
in
{
  options.local.reverse-proxy = {
    enable = mkEnableOption "reverse proxy with automatic HTTPS";

    acmeEmail = mkOption {
      type = types.str;
      default = "";
      example = "admin@example.com";
      description = "Email address for ACME/Let's Encrypt certificates";
    };

    useACME = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to use Let's Encrypt for HTTPS (requires public domain). If false, uses self-signed certificates.";
    };

    domain = mkOption {
      type = types.str;
      default = "localhost";
      example = "server.example.com";
      description = "Primary domain name for the reverse proxy";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Open firewall ports 80 and 443";
    };
    sharedFolders = mkOption {
      type = types.attrsOf types.path;
      default = { };
      example = {
        games = "/media/Media/games";
        wallpapers = "/media/Media/wallpapers";
      };
      description = "Path on disk to serve at files.onix.home";
    };
    services = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            target = mkOption {
              type = types.str;
              description = "Backend target (e.g., http://localhost:3001)";
            };

            extraConfig = mkOption {
              type = types.lines;
              default = "";
              description = "Extra Nginx configuration for this location";
            };
          };
        }
      );
      default = { };
      example = literalExpression ''
        {
          gitea.target = "http://localhost:3001";
        }
      '';
      description = "Services to proxy";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.useACME -> cfg.acmeEmail != "";
        message = "reverse-proxy: ACME requires an email address";
      }
    ];

    # Nginx reverse proxy
    security.pki.certificateFiles = [ "${onixCert}/onix.crt" ];
    services.nginx = {
      enable = true;

      recommendedProxySettings = false;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      virtualHosts =
        (mapAttrs (name: service: {
          serverName = if name == "dashboard" then cfg.domain else "${name}.${cfg.domain}";
          forceSSL = true;
          sslCertificate = "${onixCert}/onix.crt";
          sslCertificateKey = "${onixCert}/onix.key";

          locations."/" = {
            proxyPass = service.target;
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;

              # WebSocket support for modern apps
              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection $connection_upgrade;

              ${service.extraConfig}
            '';
          };
        }) cfg.services)
        // (mapAttrs (subdomain: path: {
          serverName = "${subdomain}.${cfg.domain}";
          forceSSL = true;
          sslCertificate = "${onixCert}/onix.crt";
          sslCertificateKey = "${onixCert}/onix.key";
          locations."/" = {
            extraConfig = ''
              root ${path};
              autoindex on;
              allow all;
            '';
          };
        }) cfg.sharedFolders);
    };

    # ACME configuration
    security.acme = mkIf (cfg.useACME && cfg.acmeEmail != "") {
      acceptTerms = true;
      defaults.email = cfg.acmeEmail;
    };

    # Firewall
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [
      80
      443
    ];
  };
}
