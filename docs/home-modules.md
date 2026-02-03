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
"main:CqlQUu3twINKw6EvYnbk="
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



## local\.secrets\.sopsFile



Path to the encrypted yaml file



*Type:*
absolute path



*Default:*

```nix
/nix/store/a27913vs2ir3y3lx6bajk87livakhlqr-source/secrets/secrets.yaml
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



Mapping of SSH host aliases to hostnames or IP addresses



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



Path to the SSH master private key file



*Type:*
string



*Default:*

```nix
"~/.ssh/id_ed25519"
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



Default status bar or panel application



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



Default wallpaper daemon or manager



*Type:*
string



*Default:*

```nix
"hyprpaper"
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


