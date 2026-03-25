```markdown
# ranger

This Nix module configures the ranger file manager, a console-based file manager with vi keybindings. It allows you to customize ranger's behavior through various options, including plugins, commands, settings, and previews. This module aims to provide a declarative and reproducible way to manage your ranger configuration.

## Options

This module provides the following options:

### `programs.ranger.enable`

**Type:** `Boolean`

**Default:** `false`

Enables or disables the ranger file manager. When set to `true`, the module will ensure that ranger is installed and configured according to the other options specified.

### `programs.ranger.package`

**Type:** `Package`

**Default:** `pkgs.ranger`

Specifies the ranger package to use.  This allows you to select a specific version of ranger or use a ranger package from a different source.  For example, you could use a ranger package with additional patches or a bleeding-edge development version.

### `programs.ranger.extraConfig`

**Type:** `String`

**Default:** `""`

Allows you to add arbitrary configuration directives to ranger's `rc.conf` file.  This is useful for settings that are not directly exposed as Nix options. The provided string will be appended directly to the end of `rc.conf`.  Use this for advanced configurations that require custom scripting or direct modification of ranger's settings.

### `programs.ranger.settings`

**Type:** `AttributeSet of Any`

**Default:** `{}`

A set of key-value pairs that correspond to ranger's `settings` options within `rc.conf`.  This provides a structured way to configure common ranger settings such as `show_hidden`, `column_width`, and `preview_files`. The keys of the attribute set directly map to the setting names in ranger. Values will be translated to the appropriate ranger configuration format.

**Example:**

```nix
programs.ranger.settings = {
  show_hidden = true;
  column_width = 25;
  preview_files = false;
};
```

This would generate the following in `rc.conf`:

```python
set show_hidden true
set column_width 25
set preview_files false
```

### `programs.ranger.commands`

**Type:** `AttributeSet of String`

**Default:** `{}`

A set of custom commands that will be added to ranger's command set.  The keys are the command names, and the values are the Python code implementing the command. This allows extending ranger's functionality with custom actions.

**Example:**

```nix
programs.ranger.commands = {
  mkcd = ''
    def mkcd(self):
      """Creates a directory and then cd's into it"""
      import os
      dirname = raw_input("Directory name: ")
      if dirname:
          directory = os.path.join(self.fm.thisdir.path, dirname)
          os.makedirs(directory)
          self.fm.cd(directory)
  '';
};
```

This would add a command named `mkcd` that creates a directory and then changes the current directory to the newly created one.  The command can be invoked within ranger by typing `:mkcd`.

### `programs.ranger.plugins`

**Type:** `AttributeSet of (String or { source = Path; })`

**Default:** `{}`

A set of plugins that will be installed for ranger.  The keys are the plugin names, and the values are either the plugin source code as a string or an attribute set with a `source` attribute pointing to the plugin's directory.  Using a path allows you to manage your plugins in separate files and directories.

**Example:**

```nix
programs.ranger.plugins = {
  extract_multiple = { source = ./plugins/extract_multiple; };
  custom_plugin = ''
    # Plugin code goes here
    import ranger.api
    from ranger.api.commands import Command

    class custom_plugin(Command):
      def execute(self):
        self.fm.notify("Custom plugin executed!")
  '';
};
```

This would install the `extract_multiple` plugin from the `./plugins/extract_multiple` directory and a custom plugin with inline code. Ensure the specified path exists for the plugins when using the `{ source = Path; }` option.

### `programs.ranger.defaultFileBrowser`

**Type:** `Boolean`

**Default:** `false`

If true, sets `ranger` as the default file browser in the `mimeapps.list` file, making it the default application to open directories. This requires that `xdg-utils` is available in the system environment.

### `programs.ranger.previewEnableImagePreviews`

**Type:** `Boolean`

**Default:** `true`

Enables image previews in ranger's terminal.  This requires a suitable image previewer such as `w3m-img` or `ueberzug` to be installed and configured correctly.  Disabling this option can improve performance if image previews are not needed.

### `programs.ranger.previewImageMethod`

**Type:** `Null or (Enum "w3m" "ueberzug" "kitty")`

**Default:** `null`

Specifies the method to use for image previews.  Possible values are:

*   `null`: Let ranger auto-detect an appropriate preview method based on available tools.
*   `w3m`: Use `w3m-img` for image previews. Requires `w3m` to be installed.
*   `ueberzug`: Use `ueberzug` for image previews. Requires `ueberzug` to be installed.  Provides more advanced previewing capabilities than `w3m`.
*   `kitty`: Use Kitty's graphics protocol for image previews. Requires running ranger inside the Kitty terminal emulator.

Setting this option forces ranger to use the specified method, overriding its default auto-detection.

### `programs.ranger.iconsEnableNerdfont`

**Type:** `Boolean`

**Default:** `true`

Enables the use of Nerd Font icons in ranger's display.  This requires a Nerd Font to be installed and configured in your terminal.  Disable this option if you are not using a Nerd Font or if you encounter issues with icon rendering.

### `programs.ranger.iconsUseUnicode`

**Type:** `Boolean`

**Default:** `false`

If enabled, ranger will use Unicode characters for file type icons instead of ASCII characters. This provides a richer visual representation of file types. Requires appropriate font support.  `iconsEnableNerdfont` takes precedence.

### `programs.ranger.useTrueColor`

**Type:** `Boolean`

**Default:** `true`

Enables true color support for ranger. This allows ranger to display colors with higher fidelity if your terminal supports it.  Disable this option if you encounter issues with color rendering.

### `programs.ranger.terminalEmulator`

**Type:** `String`

**Default:** `""`

Specifies the terminal emulator to use when opening files or executing commands that require a terminal.  If left empty, ranger will use the default terminal emulator configured in your system. This option is useful for specifying a particular terminal emulator for use with ranger, overriding the system default.
```
