## local\.audio\.enable

Whether to enable PipeWire based audio stack\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.backup-manager\.enable



Whether to enable backup-manager module\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.backup-manager\.backupLocation



Base path for borg backup repository (must be a mounted filesystem)



*Type:*
string



*Default:*

```nix
""
```



*Example:*

```nix
"/media/Backups"
```



## local\.backup-manager\.exclude



Glob patterns to exclude from backups



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "*/node_modules"
  "*/target"
  "*/.cache"
  "*.tmp"
]
```



## local\.backup-manager\.paths



Additional paths to backup beyond auto-discovered user folders (Projects, Documents, Pictures, Videos, \.ssh)



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "/etc/nixos"
  "/var/lib/important"
]
```



## local\.bluetooth\.enable



Whether to enable Modern Bluetooth stack\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.bootloader\.addRecoveryOption



Add recovery partition boot option to bootloader menu



*Type:*
boolean



*Default:*

```nix
false
```



## local\.bootloader\.device



Device for BIOS bootloader installation (required for BIOS mode)



*Type:*
string



*Default:*

```nix
""
```



*Example:*

```nix
"/dev/sda"
```



## local\.bootloader\.mode



Boot mode: UEFI or legacy BIOS



*Type:*
one of “uefi”, “bios”



*Default:*

```nix
"uefi"
```



## local\.bootloader\.recoveryUUID



UUID of recovery partition for boot menu entry (use blkid to find partition UUID)



*Type:*
string



*Default:*

```nix
"0d9dddd8-9511-4101-9177-0a80cfbeb047"
```



*Example:*

```nix
"12345678-1234-1234-1234-123456789abc"
```



## local\.bootloader\.uefiType



UEFI bootloader to use



*Type:*
one of “systemd-boot”, “grub”, “limine”



*Default:*

```nix
"systemd-boot"
```



## local\.cache\.enable



Whether to enable cache module\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.cache\.publicKey



Public key for cache verification



*Type:*
string



*Default:*

```nix
"main:CqlQUu3twINKw6rrCtizlAYkrPOKUicoxMyN6EvYnbk="
```



*Example:*

```nix
"cache:AbCdEf1234567890+GhIjKlMnOpQrStUvWxYz=="
```



## local\.cache\.serverAddress



Attic binary cache server URL with optional priority parameter



*Type:*
string



*Default:*

```nix
"http://10.0.0.65:8080/main?priority=1"
```



*Example:*

```nix
"http://cache.example.com:8080/nixos?priority=10"
```



## local\.cache-server\.enable



Whether to enable Attic binary cache server\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.cache-server\.allowedUsers



Users allowed to push to the cache



*Type:*
list of string



*Default:*

```nix
[
  "@wheel"
]
```



## local\.cache-server\.cacheName



Name of the cache



*Type:*
string



*Default:*

```nix
"main"
```



## local\.cache-server\.dataDir



Data directory for Attic server



*Type:*
string



*Default:*

```nix
"/var/lib/atticd"
```



## local\.cache-server\.listenAddress



Address to listen on



*Type:*
string



*Default:*

```nix
"0.0.0.0"
```



## local\.cache-server\.maxCacheSize



Maximum cache size (supports K, M, G suffixes)



*Type:*
string



*Default:*

```nix
"100G"
```



*Example:*

```nix
"500G"
```



## local\.cache-server\.openFirewall



Open firewall port for cache server



*Type:*
boolean



*Default:*

```nix
false
```



## local\.cache-server\.port



HTTP port for cache server



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
8080
```



## local\.cache-server\.serverUrl



Server URL for cache server (auto-configured based on Avahi settings)



*Type:*
string



*Default:*

```nix
"http://localhost:8080"
```



## local\.cache-server\.subPath



Subpath for reverse proxy (e\.g\., /cache)



*Type:*
string



*Default:*

```nix
""
```



*Example:*

```nix
"/cache"
```



## local\.dashboard\.enable



Whether to enable homepage dashboard\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.dashboard\.openFirewall



Open firewall port for dashboard



*Type:*
boolean



*Default:*

```nix
false
```



## local\.dashboard\.port



Port to run the dashboard on



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
3000
```



## local\.dashboard\.subPath



Subpath for reverse proxy (e\.g\., /dashboard)



*Type:*
string



*Default:*

```nix
""
```



*Example:*

```nix
"/dashboard"
```



## local\.desktops\.enable



Enable desktop environment support



*Type:*
boolean



*Default:*

```nix
false
```



## local\.desktops\.enableEnv



Enable Wayland environment variables



*Type:*
boolean



*Default:*

```nix
true
```



## local\.desktops\.hyprland



Enable Hyprland compositor



*Type:*
boolean



*Default:*

```nix
false
```



## local\.desktops\.niri



Enable Niri compositor



*Type:*
boolean



*Default:*

```nix
false
```



## local\.desktops\.plasma6



Enable KDE Plasma 6 desktop environment



*Type:*
boolean



*Default:*

```nix
false
```



## local\.dotfiles\.enable



Whether to enable Dotfiles management\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.dotfiles\.maintenance\.enable



Whether to enable System maintenance (GC and optimization)\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.dotfiles\.maintenance\.autoUpgrade



Whether to automatically pull from git and upgrade



*Type:*
boolean



*Default:*

```nix
false
```



## local\.dotfiles\.maintenance\.upgradeFlake



Flake URL for system auto-upgrade



*Type:*
string



*Default:*

```nix
"git+http://10.0.0.65:3002/xiro/dotfiles.nix.git"
```



*Example:*

```nix
"github:user/dotfiles"
```



## local\.dotfiles\.repo\.enable



Whether to enable Manage /etc/nixos permissions and symlinks\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.dotfiles\.repo\.editorGroup



Group that has write access to the /etc/nixos repository



*Type:*
string



*Default:*

```nix
"wheel"
```



*Example:*

```nix
"users"
```



## local\.dotfiles\.sync\.enable



Whether to enable Automated git sync\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.dotfiles\.sync\.interval



How often to pull changes from git (systemd time span format: 30m, 1h, 2h, etc\.)



*Type:*
string



*Default:*

```nix
"30m"
```



*Example:*

```nix
"1h"
```



## local\.download\.enable



Whether to enable download services\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.download\.downloadDir



Base directory for downloads



*Type:*
string



*Default:*

```nix
"/srv/downloads"
```



*Example:*

```nix
"/mnt/storage/downloads"
```



## local\.download\.pinchflat\.enable



Whether to enable Pinchflat YouTube downloader\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.download\.pinchflat\.baseUrl



Base URL for Pinchflat (auto-configured based on Avahi settings)



*Type:*
string



*Default:*

```nix
"http://localhost:8945"
```



## local\.download\.pinchflat\.dataDir



Data directory for Pinchflat



*Type:*
string



*Default:*

```nix
"/var/lib/pinchflat"
```



## local\.download\.pinchflat\.openFirewall



Open firewall port for Pinchflat



*Type:*
boolean



*Default:*

```nix
false
```



## local\.download\.pinchflat\.port



Web interface port



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
8945
```



## local\.download\.pinchflat\.subPath



Subpath for reverse proxy (e\.g\., /pinchflat)



*Type:*
string



*Default:*

```nix
""
```



*Example:*

```nix
"/pinchflat"
```



## local\.download\.transmission\.enable



Whether to enable Transmission BitTorrent client\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.download\.transmission\.baseUrl



Base URL for Transmission (auto-configured based on Avahi settings)



*Type:*
string



*Default:*

```nix
"http://localhost:9091"
```



## local\.download\.transmission\.downloadDirPermissions



Permissions for download directory



*Type:*
string



*Default:*

```nix
"0775"
```



## local\.download\.transmission\.openFirewall



Open firewall ports for Transmission



*Type:*
boolean



*Default:*

```nix
false
```



## local\.download\.transmission\.peerPort



Port for incoming peer connections



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
51413
```



## local\.download\.transmission\.port



Web interface port



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
9091
```



## local\.download\.transmission\.rpcWhitelist



Whitelist for RPC connections



*Type:*
string



*Default:*

```nix
"127.0.0.1,192.168.*.*,10.*.*.*"
```



## local\.download\.transmission\.subPath



Subpath for reverse proxy (e\.g\., /transmission)



*Type:*
string



*Default:*

```nix
""
```



*Example:*

```nix
"/transmission"
```



## local\.gaming\.enable



Whether to enable Gaming optimizations\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.gitea\.enable



Whether to enable Gitea Git service\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.gitea\.dataDir



Data directory for Gitea



*Type:*
string



*Default:*

```nix
"/var/lib/gitea"
```



## local\.gitea\.domain



Domain name for Gitea instance



*Type:*
string



*Default:*

```nix
"localhost"
```



*Example:*

```nix
"git.example.com"
```



## local\.gitea\.openFirewall



Open firewall ports for Gitea



*Type:*
boolean



*Default:*

```nix
false
```



## local\.gitea\.port



HTTP port for Gitea web interface



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
3001
```



## local\.gitea\.rootUrl



Root URL for Gitea



*Type:*
string



*Default:*

```nix
"http://localhost:3001/"
```



*Example:*

```nix
"https://git.example.com/"
```



## local\.gitea\.sshPort



SSH port for Git operations



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
2222
```



## local\.gitea\.subPath



Subpath for reverse proxy (e\.g\., /gitea for https://host/gitea)



*Type:*
string



*Default:*

```nix
""
```



*Example:*

```nix
"/gitea"
```



## local\.hosts\.ruby



Address for Ruby host



*Type:*
string *(read only)*



*Default:*

```nix
"10.0.0.66"
```



## local\.hosts\.sapphire



Address for Sapphire host



*Type:*
string *(read only)*



*Default:*

```nix
"10.0.0.67"
```



## local\.hosts\.useAvahi



Whether to use Avahi/mDNS hostnames (\.local) instead of raw IP addresses for local network hosts



*Type:*
boolean



*Default:*

```nix
false
```



## local\.hosts\.zimaos



Address for ZimaOS server



*Type:*
string *(read only)*



*Default:*

```nix
"10.0.0.65"
```



## local\.localization\.enable



Whether to enable Localization settings (timezone and locale)\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.localization\.locale



Default system locale for language, formatting, and character encoding



*Type:*
string



*Default:*

```nix
"en_US.UTF-8"
```



*Example:*

```nix
"en_GB.UTF-8"
```



## local\.localization\.timeZone



System timezone (use ` timedatectl list-timezones ` to see available options)



*Type:*
string



*Default:*

```nix
"America/Chicago"
```



*Example:*

```nix
"Europe/London"
```



## local\.media\.enable



Whether to enable media server stack\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.media\.ersatztv\.enable



Whether to enable ErsatzTV streaming service\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.media\.ersatztv\.baseUrl



Base URL for ErsatzTV (auto-configured based on Avahi settings)



*Type:*
string



*Default:*

```nix
"http://localhost:8409"
```



## local\.media\.ersatztv\.dataDir



Data directory for ErsatzTV



*Type:*
string



*Default:*

```nix
"/var/lib/ersatztv"
```



## local\.media\.ersatztv\.openFirewall



Open firewall port for ErsatzTV



*Type:*
boolean



*Default:*

```nix
false
```



## local\.media\.ersatztv\.port



HTTP port for ErsatzTV



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
8409
```



## local\.media\.ersatztv\.subPath



Subpath for reverse proxy (e\.g\., /ersatztv)



*Type:*
string



*Default:*

```nix
""
```



*Example:*

```nix
"/ersatztv"
```



## local\.media\.jellyfin\.enable



Whether to enable Jellyfin media server\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.media\.jellyfin\.baseUrl



Base URL for Jellyfin (auto-configured based on Avahi settings)



*Type:*
string



*Default:*

```nix
"http://localhost:8096"
```



## local\.media\.jellyfin\.dataDir



Data directory for Jellyfin



*Type:*
string



*Default:*

```nix
"/var/lib/jellyfin"
```



## local\.media\.jellyfin\.openFirewall



Open firewall port for Jellyfin



*Type:*
boolean



*Default:*

```nix
false
```



## local\.media\.jellyfin\.port



HTTP port for Jellyfin



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
8096
```



## local\.media\.jellyfin\.subPath



Subpath for reverse proxy (e\.g\., /jellyfin)



*Type:*
string



*Default:*

```nix
""
```



*Example:*

```nix
"/jellyfin"
```



## local\.media\.mediaDir



Base directory for media files



*Type:*
string



*Default:*

```nix
"/srv/media"
```



*Example:*

```nix
"/mnt/storage/media"
```



## local\.media\.plex\.enable



Whether to enable Plex media server\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.media\.plex\.baseUrl



Base URL for Plex (auto-configured based on Avahi settings)



*Type:*
string



*Default:*

```nix
"http://localhost:32400"
```



## local\.media\.plex\.dataDir



Data directory for Plex



*Type:*
string



*Default:*

```nix
"/var/lib/plex"
```



## local\.media\.plex\.openFirewall



Open firewall port for Plex



*Type:*
boolean



*Default:*

```nix
false
```



## local\.media\.plex\.port



HTTP port for Plex



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
32400
```



## local\.media\.plex\.subPath



Subpath for reverse proxy (e\.g\., /plex)\. Note: Plex has limited subpath support\.



*Type:*
string



*Default:*

```nix
""
```



*Example:*

```nix
"/plex"
```



## local\.network\.enable



Whether to enable Standard system networking\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.network\.useNetworkManager



Whether to use NetworkManager (for desktops) or just iwd/systemd (minimal)\.



*Type:*
boolean



*Default:*

```nix
true
```



## local\.registry\.enable



Whether to enable Flake registry for dotfiles\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.reverse-proxy\.enable



Whether to enable reverse proxy with automatic HTTPS\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.reverse-proxy\.acmeEmail



Email address for ACME/Let’s Encrypt certificates



*Type:*
string



*Default:*

```nix
""
```



*Example:*

```nix
"admin@example.com"
```



## local\.reverse-proxy\.domain



Primary domain name for the reverse proxy



*Type:*
string



*Default:*

```nix
"localhost"
```



*Example:*

```nix
"server.example.com"
```



## local\.reverse-proxy\.openFirewall



Open firewall ports 80 and 443



*Type:*
boolean



*Default:*

```nix
true
```



## local\.reverse-proxy\.services

Services to proxy



*Type:*
attribute set of (submodule)



*Default:*

```nix
{ }
```



*Example:*

```nix
{
  gitea = {
    path = "/gitea";
    target = "http://localhost:3001";
  };
}

```



## local\.reverse-proxy\.services\.\<name>\.extraConfig



Extra Nginx configuration for this location



*Type:*
strings concatenated with “\\n”



*Default:*

```nix
""
```



## local\.reverse-proxy\.services\.\<name>\.path



URL path for this service (e\.g\., /gitea)



*Type:*
string



## local\.reverse-proxy\.services\.\<name>\.target



Backend target (e\.g\., http://localhost:3001)



*Type:*
string



## local\.reverse-proxy\.useACME



Whether to use Let’s Encrypt for HTTPS (requires public domain)\. If false, uses self-signed certificates\.



*Type:*
boolean



*Default:*

```nix
false
```



## local\.secrets\.enable



Whether to enable sops-nix secret management\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.secrets\.keys



List of sops keys to automatically map to /run/secrets/ for system-wide access



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "zima_creds"
  "ssh_pub_ruby/master"
  "ssh_pub_sapphire/master"
]
```



## local\.secrets\.sopsFile



Path to the encrypted YAML file containing system secrets



*Type:*
absolute path



*Default:*

```nix
/nix/store/kl5326f1647cay85hgdyy3kk0wykhw1p-source/secrets/secrets.yaml
```



*Example:*

```nix
../secrets/system-secrets.yaml
```



## local\.security\.enable



Whether to enable Centralized security settings\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.security\.adminUser



The main admin user to grant passwordless sudo/doas access and SSH key authorization



*Type:*
string



*Default:*

```nix
"tod"
```



*Example:*

```nix
"admin"
```



## local\.settings\.enable



Whether to enable Basic system and Nix settings\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.shareManager\.enable



Whether to enable Samba mounts from ZimaOS\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.shareManager\.mounts



List of SMB/CIFS shares to mount automatically with systemd automount



*Type:*
list of (submodule)



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
        { shareName = "Media"; localPath = "/media/Media"; }
        { shareName = "Backups"; localPath = "/media/Backups"; noShow = true; }
      ]
```



## local\.shareManager\.mounts\.\*\.localPath



Local mount point path (common locations: /media/, /mnt/, or /run/media/)



*Type:*
string



*Example:*

```nix
"/media/Media"
```



## local\.shareManager\.mounts\.\*\.noAuth



Whether to mount as guest without authentication



*Type:*
boolean



*Default:*

```nix
false
```



## local\.shareManager\.mounts\.\*\.noShow



Whether to hide this mount from file manager



*Type:*
boolean



*Default:*

```nix
false
```



## local\.shareManager\.mounts\.\*\.options



Additional mount options to append to defaults



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "ro"
  "vers=3.0"
]
```



## local\.shareManager\.mounts\.\*\.shareName



Name of the share on the SMB server



*Type:*
string



*Example:*

```nix
"Media"
```



## local\.shareManager\.noAuth



Mount shares as guest without credentials



*Type:*
boolean



*Default:*

```nix
false
```



## local\.shareManager\.secretName



Name of sops secret containing SMB credentials (username=xxx and password=xxx format)



*Type:*
string



*Default:*

```nix
"zima_creds"
```



*Example:*

```nix
"smb_credentials"
```



## local\.shareManager\.serverIp



IP address or hostname of SMB/CIFS server



*Type:*
string



*Default:*

```nix
"10.0.0.65"
```



*Example:*

```nix
"192.168.1.100"
```



## local\.shares\.enable



Whether to enable file sharing services\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.shares\.definitions



Structured share definitions that automatically configure both Samba and NFS



*Type:*
attribute set of (submodule)



*Default:*

```nix
{ }
```



*Example:*

```nix
{
  media = {
    path = "/srv/media";
    comment = "Media files";
    readOnly = true;
    guestOk = true;
    enableNFS = true;
  };
  documents = {
    path = "/srv/documents";
    comment = "Shared documents";
    validUsers = [ "alice" "bob" ];
  };
}

```



## local\.shares\.definitions\.\<name>\.enableNFS



Also export this share via NFS



*Type:*
boolean



*Default:*

```nix
false
```



## local\.shares\.definitions\.\<name>\.browseable



Whether the share is visible in browse lists



*Type:*
boolean



*Default:*

```nix
true
```



## local\.shares\.definitions\.\<name>\.comment



Description of the share



*Type:*
string



*Default:*

```nix
""
```



## local\.shares\.definitions\.\<name>\.createMask



Permissions mask for created files



*Type:*
string



*Default:*

```nix
"0664"
```



## local\.shares\.definitions\.\<name>\.directoryMask



Permissions mask for created directories



*Type:*
string



*Default:*

```nix
"0775"
```



## local\.shares\.definitions\.\<name>\.guestOk



Allow guest access without authentication



*Type:*
boolean



*Default:*

```nix
false
```



## local\.shares\.definitions\.\<name>\.nfsClients



Network range for NFS access



*Type:*
string



*Default:*

```nix
"192.168.0.0/16"
```



*Example:*

```nix
"192.168.1.0/24"
```



## local\.shares\.definitions\.\<name>\.nfsOptions



NFS export options



*Type:*
list of string



*Default:*

```nix
[
  "rw"
  "sync"
  "no_subtree_check"
]
```



## local\.shares\.definitions\.\<name>\.path



Absolute path to the share directory



*Type:*
string



## local\.shares\.definitions\.\<name>\.readOnly



Whether the share is read-only



*Type:*
boolean



*Default:*

```nix
false
```



## local\.shares\.definitions\.\<name>\.validUsers



List of users allowed to access (empty = all users)



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "alice"
  "bob"
]
```



## local\.shares\.definitions\.\<name>\.writeable



Whether users can write to the share



*Type:*
boolean



*Default:*

```nix
true
```



## local\.shares\.nfs\.enable



Whether to enable NFS server\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.shares\.nfs\.exports



NFS exports configuration



*Type:*
strings concatenated with “\\n”



*Default:*

```nix
""
```



*Example:*

```nix
''
  /srv/shares 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
  /srv/media 192.168.1.0/24(ro,sync,no_subtree_check)
''
```



## local\.shares\.nfs\.openFirewall



Open firewall ports for NFS



*Type:*
boolean



*Default:*

```nix
false
```



## local\.shares\.samba\.enable



Whether to enable Samba server\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.shares\.samba\.openFirewall



Open firewall ports for Samba



*Type:*
boolean



*Default:*

```nix
false
```



## local\.shares\.samba\.serverString



Server description string



*Type:*
string



*Default:*

```nix
"NixOS File Server"
```



## local\.shares\.samba\.shares



Samba share definitions



*Type:*
attribute set of attribute set of unspecified value



*Default:*

```nix
{ }
```



*Example:*

```nix
{
  public = {
    path = "/srv/shares/public";
    "read only" = "no";
    browseable = "yes";
    "guest ok" = "yes";
  };
  media = {
    path = "/srv/media";
    "read only" = "yes";
    browseable = "yes";
    "guest ok" = "yes";
  };
}

```



## local\.shares\.samba\.workgroup



Samba workgroup name



*Type:*
string



*Default:*

```nix
"WORKGROUP"
```



## local\.shares\.shareDir



Base directory for shared files



*Type:*
string



*Default:*

```nix
"/srv/shares"
```



*Example:*

```nix
"/mnt/storage/shares"
```



## local\.userManager\.enable



Whether to enable Automatic user group management\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## local\.userManager\.extraGroups



Groups to assign to all auto-discovered users on this host



*Type:*
list of string



*Default:*

```nix
[
  "wheel"
  "networkmanager"
  "input"
]
```



*Example:*

```nix
[
  "wheel"
  "networkmanager"
  "input"
  "video"
  "audio"
  "docker"
]
```


