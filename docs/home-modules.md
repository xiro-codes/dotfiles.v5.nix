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
/nix/store/dcxmrmv8zfm46ifbpa1937r3qw16x0xm-source/secrets/secrets.yaml
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



## local\.stylix\.enable



Whether to enable Stylix theming system\.



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


