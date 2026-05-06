//! Application configuration management.
//!
//! This module provides configuration structures and utilities for managing
//! application settings across different environments and deployment scenarios.

use rocket::figment::Figment;

/// Application configuration container.
///
/// Holds global application settings that are loaded from configuration files,
/// environment variables, or command-line arguments via Rocket's Figment system.
///
/// # Fields
///
/// * `data_path` - Directory path for storing uploaded files and application data
pub struct AppConfig {
    pub data_path: String,
}

impl Default for AppConfig {
    /// Provides default configuration values.
    ///
    /// Returns a configuration with sensible defaults for development use.
    fn default() -> Self {
        Self {
            data_path: "/tmp/app_data".to_string(), // fallback to original development path
        }
    }
}

impl AppConfig {
    /// Creates configuration from Rocket's Figment system.
    ///
    /// Extracts configuration values from the provided Figment, falling back
    /// to defaults when values are not available.
    ///
    /// # Arguments
    ///
    /// * `figment` - Rocket's configuration provider
    ///
    /// # Returns
    ///
    /// Returns a fully configured `AppConfig` instance.
    ///
    /// # Examples
    ///
    /// ```rust,no_run
    /// use rocket::Config;
    /// use app::config::AppConfig;
    ///
    /// let figment = Config::figment();
    /// let config = AppConfig::from_figment(&figment);
    /// ```
    pub fn from_figment(figment: &Figment) -> Self {
        // Try to extract data_path from figment, otherwise use default
        let data_path = figment
            .find_value("data_path")
            .ok()
            .and_then(|v| v.as_str().map(|s| s.to_string()))
            .unwrap_or_else(|| Self::default().data_path);

        Self { 
            data_path,
        }
    }
}
