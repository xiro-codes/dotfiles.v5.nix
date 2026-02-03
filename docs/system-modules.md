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



Base path for borg backup repository



*Type:*
string



*Default:*

```nix
""
```



## local\.backup-manager\.exclude



Patterns to exclude from backups (e\.g\., node_modules, target)



*Type:*
list of string



*Default:*

```nix
[ ]
```



## local\.backup-manager\.paths



Additional paths to backup beyond auto-discovered user folders



*Type:*
list of string



*Default:*

```nix
[ ]
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



Device for BIOS bootloader installation (e\.g\., /dev/sda)



*Type:*
string



*Default:*

```nix
""
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



UUID of recovery partition for boot menu entry



*Type:*
string



*Default:*

```nix
"0d9dddd8-9511-4101-9177-0a80cfbeb047"
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



## local\.cache\.serverAddress



Attic binary cache server URL



*Type:*
string



*Default:*

```nix
"http://10.0.0.65:8080/main?priority=1"
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



Flake URL for auto-upgrade



*Type:*
string



*Default:*

```nix
"git+http://10.0.0.65:3002/xiro/dotfiles.nix.git"
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



Group that has write access to the /etc/nixos repo



*Type:*
string



*Default:*

```nix
"wheel"
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



How often to pull changes from git



*Type:*
string



*Default:*

```nix
"30m"
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



Default system locale



*Type:*
string



*Default:*

```nix
"en_US.UTF-8"
```



## local\.localization\.timeZone



System timezone



*Type:*
string



*Default:*

```nix
"America/Chicago"
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



List of sops keys to automatically map to /\.secrets/



*Type:*
list of string



*Default:*

```nix
[ ]
```



## local\.secrets\.sopsFile



Path to the encrypted yaml file



*Type:*
absolute path



*Default:*

```nix
/nix/store/dcxmrmv8zfm46ifbpa1937r3qw16x0xm-source/secrets/secrets.yaml
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



The main admin user to grant passwordless access to\.



*Type:*
string



*Default:*

```nix
"tod"
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



List of SMB/CIFS shares to mount automatically



*Type:*
list of (submodule)



*Default:*

```nix
[ ]
```



## local\.shareManager\.mounts\.\*\.localPath



Local mount point



*Type:*
string



## local\.shareManager\.mounts\.\*\.noAuth



disable auth



*Type:*
boolean



*Default:*

```nix
false
```



## local\.shareManager\.mounts\.\*\.noShow



Hide from file manager



*Type:*
boolean



*Default:*

```nix
false
```



## local\.shareManager\.mounts\.\*\.options



Extra options to add to the defaults



*Type:*
list of string



*Default:*

```nix
[ ]
```



## local\.shareManager\.mounts\.\*\.shareName



Name of the share on ZimaOS



*Type:*
string



## local\.shareManager\.noAuth



Mount shares as guest without credentials



*Type:*
boolean



*Default:*

```nix
false
```



## local\.shareManager\.secretName



Name of sops secret containing SMB credentials



*Type:*
string



*Default:*

```nix
"zima_creds"
```



## local\.shareManager\.serverIp



IP address of SMB/CIFS server



*Type:*
string



*Default:*

```nix
"10.0.0.65"
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



Groups to assign to all auto-discovered users on this host\.



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


