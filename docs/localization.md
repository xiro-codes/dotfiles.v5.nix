# localization

This module configures system-wide localization settings, including the timezone and default locale.  Enabling this module sets the system timezone and default locale, and also configures extra locale settings for various categories such as address, identification, and time.  This ensures a consistent and localized experience across the system.

## Options

### `options.local.localization.enable`

*(Type: boolean, Default: `false`)*

Enables or disables the localization settings.  When enabled, the `timeZone` and `locale` options are applied to the system configuration. This is the main switch to control whether or not the localization settings are applied.

### `options.local.localization.timeZone`

*(Type: string, Default: `"America/Chicago"`)*

Specifies the system timezone. Use `timedatectl list-timezones` to see available options.  A correct timezone setting is crucial for accurate timestamps and scheduling.

*Example:* `"Europe/London"`

### `options.local.localization.locale`

*(Type: string, Default: `"en_US.UTF-8"`)*

Specifies the default system locale for language, formatting, and character encoding.  This setting influences how the system displays dates, times, currencies, and sorts text.  UTF-8 encoding is highly recommended for broad character support.

*Example:* `"en_GB.UTF-8"`
