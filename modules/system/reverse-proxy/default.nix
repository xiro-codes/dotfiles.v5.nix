{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.reverse-proxy;
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
          path = lib.mkOption {
            type = lib.types.str;
            description = "URL path for this service (e.g., /gitea)";
          };

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
          gitea = {
            path = "/gitea";
            target = "http://localhost:3001";
          };
        }
      '';
      description = "Services to proxy";
    };
  };

  config = lib.mkIf cfg.enable {
    # Nginx reverse proxy
    services.nginx = {
      enable = true;

      recommendedProxySettings = false;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;

      virtualHosts.${cfg.domain} = {
        forceSSL = true;

        # Use ACME if configured and email provided, otherwise self-signed
        enableACME = cfg.useACME && cfg.acmeEmail != "";

        # Self-signed certificate if not using ACME
        sslCertificate = lib.mkIf (!cfg.useACME || cfg.acmeEmail == "")
          (pkgs.runCommand "self-signed-cert"
            {
              buildInputs = [ pkgs.openssl ];
            } ''
            mkdir -p $out
            openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 \
              -nodes -keyout $out/key.pem -out $out/cert.pem -subj "/CN=${cfg.domain}" \
              -addext "subjectAltName=DNS:${cfg.domain},DNS:*.${cfg.domain}"
          '' + "/cert.pem");

        sslCertificateKey = lib.mkIf (!cfg.useACME || cfg.acmeEmail == "")
          (pkgs.runCommand "self-signed-cert"
            {
              buildInputs = [ pkgs.openssl ];
            } ''
            mkdir -p $out
            openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 \
              -nodes -keyout $out/key.pem -out $out/cert.pem -subj "/CN=${cfg.domain}" \
              -addext "subjectAltName=DNS:${cfg.domain},DNS:*.${cfg.domain}"
          '' + "/key.pem");

        locations = {
          "/status" = {
            return = "200 'Server is running'";
            extraConfig = ''
              add_header Content-Type text/plain;
            '';
          };
        } // lib.mapAttrs' (name: service: 
          lib.nameValuePair service.path {
            proxyPass = service.target;
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-Host $host;
              proxy_set_header X-Forwarded-Server $host;
              proxy_set_header X-Forwarded-Prefix ${service.path};
              
              # WebSocket support (conditional)
              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection $connection_upgrade;
              
              ${service.extraConfig}
            '';
          }
        ) cfg.services;
      };
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
