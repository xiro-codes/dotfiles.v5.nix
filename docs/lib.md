```markdown
# lib

This module provides a collection of utility functions and configurations for use across various NixOS modules.  It aims to centralize commonly used logic, ensuring consistency and reducing code duplication. The functions cover areas such as network configuration, application deployment, and system administration. It also provides configurations for packages and some general helper functions for working with nix.

## Options

This module defines the following options:

### `lib.mkDeploymentUser`

*   **Type:** `types.attrsOf types.anything`
*   **Default:** `{}`

    A helper function for creating deployment users. This simplifies the creation of user accounts suitable for deploying applications or services.

    **Attributes:**

    *   `name` (string):
        The name of the user to be created. This will also be the username.

    *   `uid` (integer, optional):
        The user ID (UID) to assign to the user. If not specified, the system will automatically assign a UID.

    *   `group` (string, optional):
        The name of the primary group for the user. If not specified, a group with the same name as the user will be created.

    *   `extraGroups` (list of strings, optional):
        A list of additional groups to which the user should belong.

    *   `home` (string, optional):
        The absolute path to the user's home directory. If not specified, a home directory will be created under `/home`.

    *   `shell` (string, optional):
        The login shell for the user. Defaults to `/run/current-system/sw/bin/bash`.

    *   `isSystemUser` (boolean, optional):
        Whether the user should be created as a system user. Defaults to `false`. System users typically have UIDs below a certain threshold and are not intended for interactive login.

    **Example Usage:**

    ```nix
    lib.mkDeploymentUser {
      name = "deployer";
      uid = 2000;
      extraGroups = [ "wheel" ];
      home = "/opt/deployer";
    }
    ```

    This example creates a user named `deployer` with UID 2000, adds them to the `wheel` group, and sets their home directory to `/opt/deployer`.

### `lib.concatMapStrings`

*   **Type:** `types.functionTo (types.listOf types.str -> types.str)`
*   **Default:** A function that takes a function and a list of strings and applies the function to each element of the list and concatenates the results into a single string.

    A helper function to concatenate mapped strings. Takes a function and a list of strings as input. Applies the provided function to each string in the list, concatenates the results, and returns the final concatenated string. Useful for building configuration files or scripts from lists of values.

    **Example Usage:**

    ```nix
    let
      myList = [ "a" "b" "c" ];
      myFunction = x: "${x}!";
    in
    lib.concatMapStrings myFunction myList # Result: "a!b!c!"
    ```

### `lib.packages.zoxide.enableFzf`

*   **Type:** `types.bool`
*   **Default:** `true`

    Determines whether to enable `fzf` integration for the `zoxide` package. If enabled, `zoxide` will use `fzf` for fuzzy finding when navigating directories. Requires `fzf` to be installed.

    **Purpose:**

    This option controls whether `zoxide` leverages `fzf` for a more interactive and efficient directory navigation experience.  When enabled, users can type partial directory names, and `fzf` will provide a fuzzy search interface to quickly locate and jump to the desired directory.

    **Dependencies:**

    Enabling this option requires `fzf` to be installed and available in the user's `PATH`. You may need to add `pkgs.fzf` to your `environment.systemPackages` or `home.packages` to install it.

    **Disabling:**

    Set this option to `false` to disable `fzf` integration. This can be useful if you prefer the default `zoxide` navigation or if you do not have `fzf` installed.

    **Example Usage:**

    ```nix
    {
      lib.packages.zoxide.enableFzf = true; # Enable fzf integration (default)
    }
    ```

### `lib.packages.zoxide.settings`

*   **Type:** `types.attrs`
*   **Default:** `{}`

    Allows for customizing the settings of the `zoxide` package. This provides a way to modify `zoxide`'s behavior, such as setting default directories, search preferences, and more. The attributes defined here will directly map to `zoxide`'s configuration options. Refer to `zoxide` documentation for available settings.

    **Structure:**

    The value of this option should be an attribute set where each attribute corresponds to a `zoxide` configuration setting. The names and types of these attributes must match the expected format for `zoxide`'s configuration.

    **Example Usage:**

    ```nix
    {
      lib.packages.zoxide.settings = {
        match = "fuzzy";
        algorithm = "rankdir";
      };
    }
    ```

    This configures `zoxide` to use fuzzy matching with the `rankdir` algorithm.
    This will create a file at `~/.config/zoxide/config.toml` if it doesn't exists already or will edit this one.
    **Important:** Check `zoxide`'s official documentation for valid settings and their corresponding types. Incompatible configurations can lead to unexpected behavior or errors.

### `lib.packages.direnv.plugins`

*   **Type:** `types.listOf types.str`
*   **Default:** `[]`

    A list of plugins to be enabled for `direnv`. This enables extensibility to `direnv` so that it can have integrations with other tools and environment configurations.

    **Purpose:**
    Plugins provide additional functionality to `direnv`, allowing it to interact with various tools and environments.

    **Example Usage:**

    ```nix
    {
      lib.packages.direnv.plugins = [
        "dotenv"
      ];
    }
    ```

### `lib.ensureDirectory`

*   **Type:** `types.path`
*   **Default:** A function that takes a path and ensures the directory exists, creating it if necessary.

    A helper function to ensure a directory exists.  Takes a path as input.  If the directory specified by the path does not exist, it will be created.  If the directory already exists, no action is taken. Useful for guaranteeing the presence of directories needed for configuration files, data storage, or other purposes.

    **Example Usage:**

    ```nix
    lib.ensureDirectory "/var/log/my-app"; # Ensures that /var/log/my-app exists
    ```

### `lib.mapAttrsRecursive`

*   **Type:** `types.functionTo (types.attrs -> types.attrs)`
*   **Default:** A function that recursively maps the values of an attribute set.

    Recursively maps the values of an attribute set using a given function. This function traverses an attribute set and applies the provided function to each value. If a value is itself an attribute set, the function is applied recursively to its contents. This allows for transforming deeply nested attribute sets in a consistent manner.

    **Example Usage:**

    ```nix
    let
      myAttrs = {
        a = "value1";
        b = {
          c = "value2";
          d = "value3";
        };
      };
      myFunction = x: "mapped: ${x}";
    in
    lib.mapAttrsRecursive myFunction myAttrs

    # Result:
    # {
    #   a = "mapped: value1";
    #   b = {
    #     c = "mapped: value2";
    #     d = "mapped: value3";
    #   };
    # }
    ```
```
