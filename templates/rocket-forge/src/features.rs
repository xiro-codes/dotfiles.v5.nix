//! Feature flags and environment-specific configurations.
//!
//! This module provides compile-time feature detection and configuration
//! based on build profiles (debug vs release).

/// Feature flags for different build configurations.
///
/// Provides static methods to check feature availability based on
/// compile-time flags and build configuration.
pub struct Features;

impl Features {
    /// Check if we're in development mode.
    ///
    /// Returns `true` when compiled with debug assertions (debug build),
    /// `false` for release builds.
    ///
    /// # Examples
    ///
    /// ```rust
    /// use app::features::Features;
    ///
    /// if Features::is_development() {
    ///     println!("Running in development mode");
    /// }
    /// ```
    pub const fn is_development() -> bool {
        cfg!(debug_assertions)
    }
    
    /// Check if database seeding should be enabled.
    ///
    /// Seeding is typically enabled in development to populate the database
    /// with test data for easier development and testing.
    ///
    /// # Returns
    ///
    /// Returns `true` if ENABLE_SEEDING env var is "true" or "1".
    /// Otherwise returns `true` in debug builds, `false` in release builds.
    pub fn enable_seeding() -> bool {
        if let Ok(val) = std::env::var("ENABLE_SEEDING") {
            val == "true" || val == "1"
        } else {
            cfg!(debug_assertions)
        }
    }
    
    /// Check if detailed logging should be enabled.
    ///
    /// Detailed logging includes verbose debug information that's useful
    /// during development but may be too verbose for production.
    ///
    /// # Returns
    ///
    /// Returns `true` in debug builds, `false` in release builds.
    pub const fn enable_detailed_logging() -> bool {
        cfg!(debug_assertions)
    }
    
    /// Get the appropriate log level based on build configuration.
    ///
    /// Returns a more verbose log level for development and a more
    /// conservative level for production deployments.
    ///
    /// # Returns
    ///
    /// - `Debug` level for debug builds
    /// - `Info` level for release builds
    ///
    /// # Examples
    ///
    /// ```rust
    /// use app::features::Features;
    /// use log::LevelFilter;
    ///
    /// let level = Features::log_level();
    /// println!("Current log level: {:?}", level);
    /// ```
    pub const fn log_level() -> log::LevelFilter {
        if cfg!(debug_assertions) {
            log::LevelFilter::Debug
        } else {
            log::LevelFilter::Info
        }
    }
}