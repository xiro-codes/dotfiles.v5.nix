{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.reverse-proxy;
  onixCert = pkgs.runCommand "onix-local-cert"
    {
      buildInputs = [ pkgs.openssl ];
    } ''
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
    enable = lib.mkEnableOption "reverse proxy with automatic HTTPS";

    acmeEmail = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "admin@example.com";
      description = "Email address for ACME/Let's Encrypt certificates";
    };

    useACME = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to use Let's Encrypt for HTTPS (requires public domain). If false, uses self-signed certificates.";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
      example = "server.example.com";
      description = "Primary domain name for the reverse proxy";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open firewall ports 80 and 443";
    };

    services = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {

          target = lib.mkOption {
            type = lib.types.str;
            description = "Backend target (e.g., http://localhost:3001)";
          };

          extraConfig = lib.mkOption {
            type = lib.types.lines;
            default = "";
            description = "Extra Nginx configuration for this location";
          };
        };
      });
      default = { };
      example = lib.literalExpression ''
        {
          gitea.target = "http://localhost:3001";
        }
      '';
      description = "Services to proxy";
    };
  };

  config = lib.mkIf cfg.enable {
    # Nginx reverse proxy
    security.pki.certificateFiles = [ "${onixCert}/onix.crt" ];
    services.nginx = {
      enable = true;

      recommendedProxySettings = false;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;

      virtualHosts = lib.mapAttrs
        (name: service: {
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
        })
        cfg.services;
    };

    # ACME configuration
    security.acme = lib.mkIf (cfg.useACME && cfg.acmeEmail != "") {
      acceptTerms = true;
      defaults.email = cfg.acmeEmail;
    };

    # Firewall
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ 80 443 ];
  };
}
