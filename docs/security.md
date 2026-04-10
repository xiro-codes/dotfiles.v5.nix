# security

This module provides centralized security settings for a NixOS system, including doas and sudo configuration, SSH service hardening, authorized key management for root and a specified admin user, and Nix daemon trust configuration. It aims to simplify and standardize security configurations across multiple systems.

## Options

Here's a detailed breakdown of the available options within the `local.security` namespace:

-   **`local.security.enable`**
    *   Type: `Boolean`
    *   Default: `false` (Implied by `mkEnableOption`)
    *   Description: Enables the centralized security settings defined in this module. When enabled, the module configures `doas`, `sudo`, `openssh`, user SSH keys and nix daemon.

-   **`local.security.adminUser`**
    *   Type: `String`
    *   Default: `"tod"`
    *   Example: `"admin"`
    *   Description: Specifies the main administrative user to be granted passwordless `sudo`/`doas` access and SSH key authorization.  This user is treated as a privileged user with extended permissions.

## Configuration Details

When `local.security.enable` is set to `true`, the following configurations are applied:

### doas setup

Enables `doas` and configures it to allow the specified `adminUser` to execute commands without a password. The `keepEnv` option ensures that the user's environment variables are preserved when using `doas`.

```nix
security.doas = {
  enable = true;
  extraRules = [
    {
      users = [ cfg.adminUser ];
      keepEnv = true;
      noPass = true;
    }
  ];
};
```

### sudo setup

Enables `sudo` and configures it so the `wheel` group does not need a password.  This is included to ensure that `deploy-rs` and other systems relying on `sudo` can still function correctly.

```nix
security.sudo = {
  enable = true;
  wheelNeedsPassword = false;
};
```

### SSH Service Hardening

Configures the `openssh` service to enhance security by disabling password authentication and keyboard-interactive authentication, and prohibiting root login with a password.

```nix
services.openssh = {
  enable = true;
  settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    PermitRootLogin = "prohibit-password";
  };
};
```

### Authorized Keys

Adds the SSH public keys (sourced from SOPS secrets) to the `authorizedKeys` file for both the `root` user and the specified `adminUser`.  This allows passwordless SSH access for these users when using the corresponding private keys.

```nix
users.users.root.openssh.authorizedKeys.keyFiles = [
  config.sops.secrets."ssh_pub_ruby/master".path
  config.sops.secrets."ssh_pub_sapphire/master".path
  config.sops.secrets."ssh_pub_onix/master".path
  config.sops.secrets."ssh_pub_jade/master".path
];
users.users.${cfg.adminUser}.openssh.authorizedKeys.keyFiles = [
  config.sops.secrets."ssh_pub_ruby/master".path
  config.sops.secrets."ssh_pub_sapphire/master".path
  config.sops.secrets."ssh_pub_onix/master".path
  config.sops.secrets."ssh_pub_jade/master".path
];
```

*Note:* The `ssh_pub_ruby/master`, `ssh_pub_sapphire/master`, `ssh_pub_onix/master`, and `ssh_pub_jade/master` secrets should contain valid SSH public keys.

### Nix Daemon Trust

Configures the Nix daemon to trust both the `root` user and the specified `adminUser`.  This allows these users to perform actions that require elevated privileges, such as building and deploying NixOS configurations.  This is particularly important for remote deployments.

```nix
nix.settings.trusted-users = [ "root" cfg.adminUser ];
```

