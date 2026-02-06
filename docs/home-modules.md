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
/nix/store/5raz050gi5ss2pj4kc4imax2z1zs320n-source/secrets/secrets.yaml
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


