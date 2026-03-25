# Localization Module

This Nix module provides a convenient way to configure system-wide localization settings, including the timezone and locale. It aims to simplify the management of internationalization and localization parameters within your NixOS configuration. By enabling this module, you can easily set the default system locale and timezone, ensuring that your system displays information in the correct format for your region and language.

## Options

This module exposes the following options under the `local.localization` namespace:

### `local.localization.enable`

*   **Type:** Boolean
*   **Default:** `false` (Disabled)
*   **Description:**  Enables or disables the localization module. When enabled, the module will configure the system timezone and locale based on the settings provided.  Setting this to `true` activates the module and applies the specified localization settings.

### `local.localization.timeZone`

*   **Type:** String
*   **Default:** `"America/Chicago"`
*   **Example:** `"Europe/London"`
*   **Description:** Specifies the system timezone. This setting controls how the system interprets and displays dates and times.  It's crucial to set this correctly to ensure accurate timekeeping and scheduling. You can use the `timedatectl list-timezones` command to see a list of available timezones on your system. Make sure to select a valid timezone from the list.

### `local.localization.locale`

*   **Type:** String
*   **Default:** `"en_US.UTF-8"`
*   **Example:** `"en_GB.UTF-8"`
*   **Description:** Defines the default system locale. The locale setting influences how language, formatting (e.g., date, time, currency), and character encoding are handled system-wide.  It determines the language used in system messages, the format of numbers and dates, and the character encoding used for displaying text. Common locales include `"en_US.UTF-8"` (US English), `"en_GB.UTF-8"` (British English), and `"de_DE.UTF-8"` (German).  Choosing the correct locale ensures a consistent and appropriate user experience. Setting this option also configures `i18n.extraLocaleSettings` for comprehensive localization.
