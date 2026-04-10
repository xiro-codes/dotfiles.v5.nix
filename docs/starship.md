# starship

This module configures the Starship prompt, a cross-shell prompt that's customizable and fast. It enables Starship with Fish shell integration and sets up a specific prompt format with customizations for username, hostname, directory, Git branch, Nix shell, Rust, Python, and shell level.

## Options

### `local.starship.enable`

Type: boolean

Default value: `false`

Description: Enables the Starship prompt configuration. When enabled, this option configures Starship to be the active prompt in your shell, specifically enabling it for Fish and setting a pre-defined prompt format.

## Configuration Details

When `local.starship.enable` is set to `true`, the following configurations are applied to Starship:

*   **`programs.starship.enable`**:  Enables Starship itself.
*   **`programs.starship.enableFishIntegration`**: Enables integration with the Fish shell for seamless prompt functionality.
*   **`programs.starship.settings`**: Defines the detailed settings for the Starship prompt, including formatting and styles for various segments.

    *   **`add_newline`**: Disables the addition of a newline before the prompt.
    *   **`line_break.disabled`**: Disables the line break feature, keeping the prompt on a single line.
    *   **`format`**: Defines the overall structure of the prompt, including username, hostname, directory, Git branch, Nix shell, Rust, Python, shell level, and character. The format string is: `(white)$username@$hostname $directory($git_branch)$nix_shell$rust$python$shlvl$character`.

    The following sections outline the specific settings for each segment of the prompt:

    *   **`username`**:
        *   `show_always`: Always shows the username, regardless of the user context.
        *   `format`: Defines the format of the username segment as `[$user]($style)`.
        *   `style_user`: Sets the style of the username to white.
    *   **`hostname`**:
        *   `ssh_only`:  Does not limit the hostname display to only SSH sessions (set to false so it is displayed locally as well).
        *   `format`: Defines the format of the hostname segment as `[$hostname]($style) `.
        *   `style`: Sets the style of the hostname to white.
    *   **`directory`**:
        *   `style`: Sets the style of the directory to blue.
        *   `truncation_length`: Sets the truncation length for directory paths to 3.
        *   `fish_style_pwd_dir_length`: Sets the directory length to 1 (behaves like Fish shell’s `~/P/style`).
    *   **`git_branch`**:
        *   `symbol`: Removes the default branch icon.
        *   `format`: Defines the format of the Git branch segment as `([$branch]($style)) `.
        *   `style`: Sets the style of the Git branch to white.
    *   **`nix_shell`**:
        *   `symbol`: Sets the symbol for Nix shell to "❄️".
        *   `format`: Defines the format of the Nix shell segment as `[$symbol]($style) `.
        *   `style`: Sets the style of the Nix shell to bold blue.
    *   **`rust`**:
        *   `symbol`: Sets the symbol for Rust to "🦀".
        *   `format`: Defines the format of the Rust segment as `[$symbol]($style) `.
        *   `style`: Sets the style of the Rust to bold red.
    *   **`python`**:
        *   `symbol`: Sets the symbol for Python to "🐍".
        *   `format`: Defines the format of the Python segment as `[$symbol]($style) `.
        *   `style`: Sets the style of the Python to yellow.
    *   **`shlvl`**:
        *   `disabled`: Shows the shell level at or above the defined threshold
        *   `symbol`: Sets the symbol for the Shell Level to "🐚".
        *   `threshold`: Sets the threshold for when the shell level is displayed to 3 or higher.
        *   `format`: Defines the format of the shell level segment as `[$symbol$shlvl]($style) `.
    *   **`character`**:
        *   `success_symbol`: Sets the success symbol to `[\u003e](bold white)`.
        *   `error_symbol`: Sets the error symbol to `[\u003e](bold red)`.

