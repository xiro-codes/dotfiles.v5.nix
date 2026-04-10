```markdown
# kmscon

This Nix module configures the `kmscon` terminal emulator, primarily intended for use on servers without a graphical interface. It allows you to enable and customize `kmscon` to provide a console-based terminal experience.

## Options

### `local.kmscon.enable`

Type: `Boolean`

Default: `false`

Description: Enables or disables the `kmscon` terminal emulator service. When set to `true`, the `kmscon` service will be activated with the configurations specified in the module.

## Configuration Details

When `local.kmscon.enable` is set to `true`, the following configuration is applied:

*   **`services.kmscon.enable`**: This option is automatically set to `true`, enabling the `kmscon` service managed by NixOS.

*   **`services.kmscon.hwRender`**: This option is automatically set to `true`, which enables hardware rendering in `kmscon`. This typically results in better performance and smoother rendering.

*   **`services.kmscon.fonts`**: This option is set to a list containing a single font configuration in this module:

    *   **`name`**: Specifies the name of the font to use, set to `"Cascadia Code"`.
    *   **`package`**: Specifies the Nix package containing the font, set to `pkgs.cascadia-code`.  This ensures that the Cascadia Code font is available for `kmscon` to use. You can add more fonts by adding other elements to the list.  Example: `{ name = "Another Font"; package = pkgs.another-font; }`

This module provides a basic setup for `kmscon` using hardware rendering and the Cascadia Code font.  Further customization of `kmscon` can be achieved by extending the `services.kmscon` configuration. Please refer to the NixOS options documentation for `services.kmscon` for more options.
```
