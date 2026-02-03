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
/nix/store/ik3c7pk4n6xcs5yj95gjrfivchx88b4l-source/secrets/secrets.yaml
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


