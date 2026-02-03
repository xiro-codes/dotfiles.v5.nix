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



## local\.gitSync\.enable



Whether to enable Automated git sync \.



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



## local\.gitSync\.interval



How often to pull changes



*Type:*
string



*Default:*

```nix
"30m"
```



## local\.maintenance\.enable



Whether to enable maintenance module\.



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



## local\.maintenance\.autoUpgrade



Whether to automatically pull from git and upgrade\.



*Type:*
boolean



*Default:*

```nix
false
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



## local\.repoManager\.enable



Whether to enable Manage /etc/nixos\.



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



## local\.repoManager\.editorGroup



Group that has write access to the /etc/nixos repo



*Type:*
string



*Default:*

```nix
"wheel"
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
/nix/store/rpfwsmwsvhsz1mjsghl3lh5mlh3h7lv0-source/secrets/secrets.yaml
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



Whether to enable Enable basic settings\.



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



## Home Manager Modules

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
"http://10.0.0.65:8080/main"
```



## local\.cache\.watch



Whether to enable enable systemd service to watch cache\.



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



## local\.fish\.enable



Enable fish config if it is the system shell\.



*Type:*
boolean



*Default:*

```nix
false
```



## local\.fonts\.enable



Whether to enable Enable nerdfonts\.



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



Whether to enable Enable native hyprland launcher\.



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



Whether to enable Native Hyprland wallpaper daemon\.



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



List of wallpapers to preload



*Type:*
list of absolute path



*Default:*

```nix
[ ]
```



## local\.kitty\.enable



Whether to enable Enable kitty\.



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



Whether to enable mako module\.



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



Whether to enable Enable mpd\.



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



Path to music directory for MPD



*Type:*
string



*Default:*

```nix
"/mnt/zima/Music"
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



Whether to enable enable ranger\.



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



## local\.secrets\.sopsFile



Path to the encrypted yaml file



*Type:*
absolute path



*Default:*

```nix
/nix/store/rpfwsmwsvhsz1mjsghl3lh5mlh3h7lv0-source/secrets/secrets.yaml
```



## local\.shell\.enable



Whether to enable shell module\.



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



Mapping of aliases to hostnames/IPs\.



*Type:*
attribute set of string



*Default:*

```nix
{ }
```



*Example:*

```nix
{
  Ruby = "10.0.0.66";
  Sapphire = "10.0.0.67";
}
```



## local\.ssh\.masterKeyPath



Fixed path to the private master key\.



*Type:*
string



*Default:*

```nix
"~/.ssh/id_ed25519"
```



## local\.theming\.enable



Whether to enable theming module\.



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



Whether to enable System variables\.



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



## local\.variables\.browser



Default web browser



*Type:*
string



*Default:*

```nix
"firefox"
```



## local\.variables\.editor



Default terminal text editor



*Type:*
string



*Default:*

```nix
"nvim"
```



## local\.variables\.fileManager



Default terminal file manager



*Type:*
string



*Default:*

```nix
"ranger"
```



## local\.variables\.guiEditor



Default GUI text editor



*Type:*
string



*Default:*

```nix
"neovide"
```



## local\.variables\.guiFileManager



Default GUI file manager



*Type:*
string



*Default:*

```nix
"pcmanfm"
```



## local\.variables\.launcher



Default application launcher command



*Type:*
string



*Default:*

```nix
"rofi -show drun"
```



## local\.variables\.statusBar



Default status bar/panel



*Type:*
string



*Default:*

```nix
"hyprpanel"
```



## local\.variables\.terminal



Default terminal emulator



*Type:*
string



*Default:*

```nix
"kitty"
```



## local\.variables\.wallpaper



Default wallpaper daemon



*Type:*
string



*Default:*

```nix
"hyprpaper"
```



## local\.waybar\.enable



Whether to enable Enable waybar\.



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


