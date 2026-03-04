# security

This Nix module provides centralized security settings for a NixOS system. It configures `doas` and `sudo` for passwordless administrative access, hardens the SSH service, applies SSH keys to the root and admin user, and sets up Nix daemon trust for remote deployments.  It primarily aims to improve the security posture of a NixOS system with sensible defaults and easy customization.

## Options

### `local.security.enable`

Type: boolean

Default: `false`

Description: Enables the centralized security settings provided by this module. When enabled, `doas`, `sudo`, SSH hardening, SSH key deployment, and Nix daemon trust settings are applied.

### `local.security.adminUser`

Type: string

Default: `"tod"`

Example: `"admin"`

Description: The main admin user to grant passwordless `sudo`/`doas` access and SSH key authorization. This user will be granted `doas` and `sudo` access without a password, and their SSH keys will be authorized for login.  This is the primary administrative account.
