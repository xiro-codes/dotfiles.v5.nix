# NixOS Dotfiles Documentation

Auto-generated documentation for custom modules.

## System Modules

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



## local\.dashboard\.allowedHosts



List of allowed hostnames for accessing the dashboard (for reverse proxy)\. Defaults to hostname, IP, and \.local address\.



*Type:*
list of string



*Default:*

```nix
[
  "localhost"
  "127.0.0.1"
]
```



*Example:*

```nix
[
  "onix.local"
  "192.168.1.100"
]
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



## local\.disks\.enable



Whether to enable basic configuration for disk management\.



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



## local\.downloads\.enable



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



## local\.downloads\.downloadDir



Base directory for downloads



*Type:*
string



*Default:*

```nix
"/media/Media/downloads"
```



*Example:*

```nix
"/mnt/storage/downloads"
```



## local\.downloads\.pinchflat\.enable



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



## local\.downloads\.pinchflat\.baseUrl



Base URL for Pinchflat (auto-configured based on reverse proxy and Avahi settings)



*Type:*
string



*Default:*

```nix
"http://localhost:8945"
```



## local\.downloads\.pinchflat\.dataDir



Data directory for Pinchflat



*Type:*
string



*Default:*

```nix
"/var/lib/pinchflat"
```



## local\.downloads\.pinchflat\.openFirewall



Open firewall port for Pinchflat



*Type:*
boolean



*Default:*

```nix
false
```



## local\.downloads\.pinchflat\.port



Web interface port



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
8945
```



## local\.downloads\.pinchflat\.subPath



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



## local\.downloads\.prowlarr\.enable



Whether to enable Prowlarr indexer manager\.



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



## local\.downloads\.prowlarr\.openFirewall



Open firewall port for Prowlarr



*Type:*
boolean



*Default:*

```nix
false
```



## local\.downloads\.prowlarr\.port



Web interface port



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
9696
```



## local\.downloads\.qbittorrent\.enable



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



## local\.downloads\.qbittorrent\.openFirewall



Open firewall ports for Transmission



*Type:*
boolean



*Default:*

```nix
false
```



## local\.downloads\.qbittorrent\.port



Web interface port



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
8080
```



## local\.downloads\.qbittorrent\.subPath



Subpath for reverse proxy (e\.g\., /transmission)



*Type:*
string



*Default:*

```nix
""
```



*Example:*

```nix
"/qbittorrent"
```



## local\.downloads\.sonarr\.enable



Whether to enable Sonarr PVR\.



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



## local\.downloads\.sonarr\.openFirewall



Open firewall port for Sonarr



*Type:*
boolean



*Default:*

```nix
false
```



## local\.downloads\.sonarr\.port



Web interface port



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
8989
```



## local\.downloads\.transmission\.enable



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



## local\.downloads\.transmission\.baseUrl



Base URL for Transmission (auto-configured based on reverse proxy and Avahi settings)



*Type:*
string



*Default:*

```nix
"http://localhost:9091"
```



## local\.downloads\.transmission\.downloadDirPermissions



Permissions for download directory



*Type:*
string



*Default:*

```nix
"0775"
```



## local\.downloads\.transmission\.openFirewall



Open firewall ports for Transmission



*Type:*
boolean



*Default:*

```nix
false
```



## local\.downloads\.transmission\.peerPort



Port for incoming peer connections



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
51413
```



## local\.downloads\.transmission\.port



Web interface port



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
9091
```



## local\.downloads\.transmission\.rpcWhitelist



Whitelist for RPC connections



*Type:*
string



*Default:*

```nix
"onix.local,127.0.0.1,192.168.*.*,10.*.*.*"
```



## local\.downloads\.transmission\.subPath



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



## local\.file-browser\.enable



Whether to enable Web-based file browser\.



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



## local\.file-browser\.dataDir



Directory for File Browser database and config



*Type:*
string



*Default:*

```nix
"/var/lib/filebrowser"
```



## local\.file-browser\.openFirewall



Open firewall port for File Browser



*Type:*
boolean



*Default:*

```nix
false
```



## local\.file-browser\.port



Web interface port



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
8082
```



## local\.file-browser\.rootPath



Root path to serve files from



*Type:*
string



*Default:*

```nix
"/media"
```



## local\.file-browser\.subPath



Subpath for reverse proxy (e\.g\., /files)



*Type:*
string



*Default:*

```nix
""
```



*Example:*

```nix
"/files"
```



## local\.file-sharing\.enable



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



## local\.file-sharing\.definitions



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



## local\.file-sharing\.definitions\.\<name>\.enableNFS



Also export this share via NFS



*Type:*
boolean



*Default:*

```nix
false
```



## local\.file-sharing\.definitions\.\<name>\.browseable



Whether the share is visible in browse lists



*Type:*
boolean



*Default:*

```nix
true
```



## local\.file-sharing\.definitions\.\<name>\.comment



Description of the share



*Type:*
string



*Default:*

```nix
""
```



## local\.file-sharing\.definitions\.\<name>\.createMask



Permissions mask for created files



*Type:*
string



*Default:*

```nix
"0666"
```



## local\.file-sharing\.definitions\.\<name>\.directoryMask



Permissions mask for created directories



*Type:*
string



*Default:*

```nix
"0777"
```



## local\.file-sharing\.definitions\.\<name>\.guestOk



Allow guest access without authentication



*Type:*
boolean



*Default:*

```nix
false
```



## local\.file-sharing\.definitions\.\<name>\.nfsClients



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



## local\.file-sharing\.definitions\.\<name>\.nfsOptions



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



## local\.file-sharing\.definitions\.\<name>\.path



Absolute path to the share directory



*Type:*
string



## local\.file-sharing\.definitions\.\<name>\.readOnly



Whether the share is read-only



*Type:*
boolean



*Default:*

```nix
false
```



## local\.file-sharing\.definitions\.\<name>\.validUsers



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



## local\.file-sharing\.definitions\.\<name>\.writeable



Whether users can write to the share



*Type:*
boolean



*Default:*

```nix
true
```



## local\.file-sharing\.nfs\.enable



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



## local\.file-sharing\.nfs\.exports



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



## local\.file-sharing\.nfs\.openFirewall



Open firewall ports for NFS



*Type:*
boolean



*Default:*

```nix
false
```



## local\.file-sharing\.samba\.enable



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



## local\.file-sharing\.samba\.openFirewall



Open firewall ports for Samba



*Type:*
boolean



*Default:*

```nix
false
```



## local\.file-sharing\.samba\.serverString



Server description string



*Type:*
string



*Default:*

```nix
"NixOS File Server"
```



## local\.file-sharing\.samba\.shares



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



## local\.file-sharing\.samba\.workgroup



Samba workgroup name



*Type:*
string



*Default:*

```nix
"WORKGROUP"
```



## local\.file-sharing\.shareDir



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



## local\.gitea-runner\.enable



Whether to enable Gitea Actions Runner\.



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



## local\.gitea-runner\.giteaUrl



URL of the Gitea instance to connect to



*Type:*
string



*Default:*

```nix
"http://127.0.0.1:3001"
```



## local\.gitea-runner\.instanceName



Name of the runner instance



*Type:*
string



*Default:*

```nix
"default-runner"
```



## local\.gitea-runner\.labels



Labels for the runner



*Type:*
list of string



*Default:*

```nix
[
  "ubuntu-latest:docker://node:18-bullseye"
  "ubuntu-22.04:docker://node:18-bullseye"
  "ubuntu-20.04:docker://node:16-bullseye"
  "nixos-latest:docker://nixos/nix:latest"
]
```



## local\.gitea-runner\.tokenFile



Path to the file containing the runner registration token



*Type:*
string



*Default:*

```nix
"/run/secrets/gitea/runner_token"
```



## local\.hosts\.onix



Address for Onix host



*Type:*
string *(read only)*



*Default:*

```nix
"10.0.0.65"
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



Base URL for ErsatzTV (auto-configured based on reverse proxy and Avahi settings)



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



Base URL for Jellyfin (auto-configured based on reverse proxy and Avahi settings)



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
"/media/Media"
```



*Example:*

```nix
"/media/Media"
```



## local\.media\.plex\.enable



Whether to enable Plex Media Server\.



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



## local\.network-mounts\.enable



Whether to enable Samba mounts from Onix\.



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



## local\.network-mounts\.mounts



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



## local\.network-mounts\.mounts\.\*\.localPath



Local mount point path (common locations: /media/, /mnt/, or /run/media/)



*Type:*
string



*Example:*

```nix
"/media/Media"
```



## local\.network-mounts\.mounts\.\*\.noAuth



Whether to mount as guest without authentication



*Type:*
boolean



*Default:*

```nix
false
```



## local\.network-mounts\.mounts\.\*\.noShow



Whether to hide this mount from file manager



*Type:*
boolean



*Default:*

```nix
false
```



## local\.network-mounts\.mounts\.\*\.options



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



## local\.network-mounts\.mounts\.\*\.shareName



Name of the share on the SMB server



*Type:*
string



*Example:*

```nix
"Media"
```



## local\.network-mounts\.noAuth



Mount shares as guest without credentials



*Type:*
boolean



*Default:*

```nix
false
```



## local\.network-mounts\.secretName



Name of sops secret containing SMB credentials (username=xxx and password=xxx format)



*Type:*
string



*Default:*

```nix
"onix_creds"
```



*Example:*

```nix
"smb_credentials"
```



## local\.network-mounts\.serverIp



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



## local\.pihole\.enable



Whether to enable Pi-hole DNS service\.



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



## local\.pihole\.adminPassword



Admin password for the Pi-hole Web UI\.



*Type:*
string



*Default:*

```nix
"admin"
```



## local\.pihole\.dataDir



Directory to store Pi-hole configuration and data\.



*Type:*
string



*Default:*

```nix
"/var/lib/pihole"
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
  gitea.target = "http://localhost:3001";
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
  "onix_creds"
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
/nix/store/l2p9i2ni8rq8fk3al7y95barrpwb2y0c-source/secrets/secrets.yaml
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



## Home Manager Modules

## local\.caelestia\.enable



Whether to enable Caelestia shell application\.



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



## local\.caelestia\.colorScheme

Color scheme name for Caelestia (e\.g\., ‘gruvbox’, ‘catppuccin’)\. If null, uses dynamic wallpaper colors\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"gruvbox"
```



## local\.fish\.enable



Enable fish config if it is the system shell\.



*Type:*
boolean



*Default:*

```nix
false
```



## local\.fonts\.enable



Whether to enable Nerd Fonts collection including Fira Code, Noto fonts, and emoji support\.



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



## local\.hyprland\.enable



Whether to enable Functional Hyprland setup…



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



## local\.hyprlauncher\.enable



Whether to enable Hyprlauncher, the native Hyprland application launcher\.



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



## local\.hyprpaper\.enable



Whether to enable Hyprpaper, the native Hyprland wallpaper daemon\.



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



## local\.hyprpaper\.wallpapers



List of wallpaper paths to preload for Hyprpaper



*Type:*
list of absolute path



*Default:*

```nix
[ ]
```



*Example:*

```nix
[ ./wallpapers/gruvbox.png ./wallpapers/catppuccin.jpg ]
```



## local\.kitty\.enable



Whether to enable Kitty terminal emulator with custom configuration\.



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



## local\.mako\.enable



Whether to enable Mako notification daemon for Wayland\.



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



## local\.mpd\.enable



Whether to enable MPD (Music Player Daemon) with ncmpcpp client\.



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



## local\.mpd\.path



Path to the music directory for MPD to serve



*Type:*
string



*Default:*

```nix
"/media/Music"
```



*Example:*

```nix
"/home/user/Music"
```



## local\.nixvim\.enable



Enable nixvim configuration



*Type:*
boolean



*Default:*

```nix
false
```



## local\.nixvim\.rust



Enable Rust language support



*Type:*
boolean



*Default:*

```nix
false
```



## local\.nixvim\.smartUndo



Enable persistent undo with smart directory management



*Type:*
boolean



*Default:*

```nix
true
```



## local\.ranger\.enable



Whether to enable Ranger terminal-based file manager with devicons support\.



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



## local\.secrets\.enable



Whether to enable Use secrets\.



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



List sops keys to automatically map to $HOME/\.secrets/



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "github/token"
  "api/openai"
  "passwords/vpn"
]
```



## local\.secrets\.sopsFile



Path to the encrypted yaml file



*Type:*
absolute path



*Default:*

```nix
/nix/store/l2p9i2ni8rq8fk3al7y95barrpwb2y0c-source/secrets/secrets.yaml
```



*Example:*

```nix
../secrets/user-secrets.yaml
```



## local\.ssh\.enable



Whether to enable configure ssh for user\.



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



## local\.ssh\.hosts



Mapping of SSH host aliases to hostnames or IP addresses (automatically uses hosts from local\.hosts module)



*Type:*
attribute set of string



*Default:*

```nix
{
  Ruby = "ruby.local";
  Sapphire = "sapphire.local";
}
```



*Example:*

```nix
{
  Ruby = "ruby.local";
  Sapphire = "sapphire.local";
}
```



## local\.ssh\.masterKeyPath



Path to the SSH master private key file



*Type:*
string



*Default:*

```nix
"~/.ssh/id_ed25519"
```



*Example:*

```nix
"~/.ssh/id_rsa"
```



## local\.stylix\.enable



Whether to enable Stylix automatic theming system based on wallpaper colors\.



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



## local\.variables\.enable



Enable system environment variables for common tools and applications



*Type:*
boolean



*Default:*

```nix
true
```



## local\.variables\.browser



Default web browser



*Type:*
string



*Default:*

```nix
"firefox"
```



*Example:*

```nix
"chromium"
```



## local\.variables\.editor



Default terminal text editor



*Type:*
string



*Default:*

```nix
"nvim"
```



*Example:*

```nix
"vim"
```



## local\.variables\.fileManager



Default terminal file manager



*Type:*
string



*Default:*

```nix
"ranger"
```



*Example:*

```nix
"lf"
```



## local\.variables\.guiEditor



Default GUI text editor



*Type:*
string



*Default:*

```nix
"neovide"
```



*Example:*

```nix
"code"
```



## local\.variables\.guiFileManager



Default GUI file manager



*Type:*
string



*Default:*

```nix
"pcmanfm"
```



*Example:*

```nix
"nautilus"
```



## local\.variables\.launcher



Default application launcher command



*Type:*
string



*Default:*

```nix
"rofi -show drun"
```



*Example:*

```nix
"wofi --show drun"
```



## local\.variables\.statusBar



Default status bar or panel application



*Type:*
string



*Default:*

```nix
"hyprpanel"
```



*Example:*

```nix
"waybar"
```



## local\.variables\.terminal



Default terminal emulator



*Type:*
string



*Default:*

```nix
"kitty"
```



*Example:*

```nix
"alacritty"
```



## local\.variables\.wallpaper



Default wallpaper daemon or manager



*Type:*
string



*Default:*

```nix
"hyprpaper"
```



*Example:*

```nix
"swaybg"
```



## local\.waybar\.enable



Whether to enable Waybar status bar for Wayland compositors\.



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


