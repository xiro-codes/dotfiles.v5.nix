//! Database configuration and auto-fallback functionality.
//!
//! This module provides utilities for automatic database selection with PostgreSQL-to-SQLite
//! fallback capability and CLI argument support for database selection.

use clap::{Arg, ArgMatches, Command};
use log::{info, warn, error};
use sea_orm::{Database, DatabaseBackend, ConnectOptions, ConnectionTrait};
use std::time::Duration;

/// Database types supported by the application
#[derive(Debug, Clone, PartialEq)]
pub enum DatabaseType {
    PostgreSQL,
    SQLite,
    SQLiteMemory,
}

impl DatabaseType {
    /// Convert from string representation
    pub fn from_str(s: &str) -> Option<Self> {
        match s.to_lowercase().as_str() {
            "postgres" | "postgresql" | "pg" => Some(Self::PostgreSQL),
            "sqlite" => Some(Self::SQLite),
            "memory" | "sqlite-memory" => Some(Self::SQLiteMemory),
            _ => None,
        }
    }

    /// Get the display name for this database type
    pub fn display_name(&self) -> &'static str {
        match self {
            Self::PostgreSQL => "PostgreSQL",
            Self::SQLite => "SQLite",
            Self::SQLiteMemory => "SQLite (in-memory)",
        }
    }
}

/// Database configuration structure
#[derive(Debug, Clone)]
pub struct DatabaseConfig {
    pub db_type: DatabaseType,
    pub url: String,
    pub auto_fallback: bool,
}

impl DatabaseConfig {
    /// Create database configuration from command line arguments
    pub fn from_args(args: &ArgMatches) -> Self {
        let db_type = args
            .get_one::<String>("database")
            .and_then(|s| DatabaseType::from_str(s))
            .unwrap_or(DatabaseType::PostgreSQL);

        let auto_fallback = args.get_flag("auto-fallback");

        let url = match db_type {
            DatabaseType::PostgreSQL => {
                // Default PostgreSQL URL, can be overridden by environment
                std::env::var("DATABASE_URL")
                    .unwrap_or_else(|_| "postgres://master:password@localhost/app_dev".to_string())
            }
            DatabaseType::SQLite => {
                "sqlite:app.db?mode=rwc".to_string()
            }
            DatabaseType::SQLiteMemory => {
                "sqlite::memory:".to_string()
            }
        };

        Self {
            db_type,
            url,
            auto_fallback,
        }
    }

    /// Create default configuration with auto-fallback enabled
    pub fn default_with_fallback() -> Self {
        Self {
            db_type: DatabaseType::PostgreSQL,
            url: std::env::var("DATABASE_URL")
                .or_else(|_| std::env::var("ROCKET_DATABASES__SEA_ORM__URL"))
                .unwrap_or_else(|_| "postgres://master:password@localhost/app_dev".to_string()),
            auto_fallback: true,
        }
    }

    /// Test database connection and return the backend that actually works
    pub async fn test_and_select_database(&mut self) -> Result<DatabaseBackend, String> {
        info!("Testing database connection for {}", self.db_type.display_name());
        
        // Try the primary database first
        match self.try_connect(&self.url).await {
            Ok(backend) => {
                info!("Successfully connected to {}", self.db_type.display_name());
                return Ok(backend);
            }
            Err(e) => {
                warn!("Failed to connect to {}: {}", self.db_type.display_name(), e);
                
                if !self.auto_fallback {
                    return Err(format!("Database connection failed and auto-fallback is disabled: {}", e));
                }
            }
        }

        // If auto-fallback is enabled and primary database failed, try in-memory SQLite
        if self.auto_fallback {
            info!("Auto-fallback enabled, trying in-memory SQLite database...");
            let fallback_url = "sqlite::memory:".to_string();
            
            match self.try_connect(&fallback_url).await {
                Ok(backend) => {
                    warn!("Fell back to in-memory SQLite database. Data will not persist!");
                    self.db_type = DatabaseType::SQLiteMemory;
                    self.url = fallback_url;
                    return Ok(backend);
                }
                Err(e) => {
                    error!("Even fallback database failed: {}", e);
                    return Err(format!("All database options failed. Last error: {}", e));
                }
            }
        }

        Err("No database connection could be established".to_string())
    }

    /// Attempt to connect to a database URL and return the backend type
    async fn try_connect(&self, url: &str) -> Result<DatabaseBackend, String> {
        let mut opts = ConnectOptions::new(url);
        opts.connect_timeout(Duration::from_secs(5))
            .idle_timeout(Duration::from_secs(60));

        match Database::connect(opts).await {
            Ok(conn) => {
                let backend = conn.get_database_backend();
                // Close the test connection
                let _ = conn.close().await;
                Ok(backend)
            }
            Err(e) => Err(format!("Connection failed: {}", e)),
        }
    }

    /// Get the final database URL to use
    pub fn get_url(&self) -> &str {
        &self.url
    }

    /// Check if this is an in-memory database
    pub fn is_memory_database(&self) -> bool {
        matches!(self.db_type, DatabaseType::SQLiteMemory)
    }
}

/// Add database-related CLI arguments to a clap Command
pub fn add_database_args(cmd: Command) -> Command {
    cmd.arg(
        Arg::new("database")
            .long("database")
            .short('d')
            .value_name("TYPE")
            .help("Database type to use")
            .long_help("Database type to use. Options: postgres, sqlite, memory")
            .value_parser(["postgres", "postgresql", "pg", "sqlite", "memory", "sqlite-memory"])
    )
    .arg(
        Arg::new("auto-fallback")
            .long("auto-fallback")
            .help("Enable automatic fallback to in-memory SQLite if PostgreSQL fails")
            .long_help("If enabled, the application will automatically fall back to an in-memory SQLite database if the primary PostgreSQL database is not available")
            .action(clap::ArgAction::SetTrue)
    )
}

/// Parse command line arguments for database configuration
pub fn parse_database_args() -> DatabaseConfig {
    let cmd = Command::new("rocket_blog")
        .version("0.1.0")
        .about("A modern blog application with dual database support")
        .long_about("Rocket Blog supports both PostgreSQL and SQLite databases with automatic fallback capabilities");

    let cmd = add_database_args(cmd);
    let matches = cmd.get_matches();
    
    DatabaseConfig::from_args(&matches)
}

/// Parse command line arguments with auto-fallback enabled by default
pub fn parse_database_args_with_fallback() -> DatabaseConfig {
    let cmd = Command::new("rocket_blog")
        .version("0.1.0")
        .about("A modern blog application with dual database support")
        .long_about("Rocket Blog supports both PostgreSQL and SQLite databases with automatic fallback capabilities");

    let cmd = add_database_args(cmd);
    let matches = cmd.get_matches();
    
    let mut config = DatabaseConfig::from_args(&matches);
    
    // Enable auto-fallback by default if no explicit database type was specified
    if !matches.contains_id("database") && !matches.get_flag("auto-fallback") {
        config.auto_fallback = true;
    }
    
    config
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_database_type_from_str() {
        assert_eq!(DatabaseType::from_str("postgres"), Some(DatabaseType::PostgreSQL));
        assert_eq!(DatabaseType::from_str("postgresql"), Some(DatabaseType::PostgreSQL));
        assert_eq!(DatabaseType::from_str("pg"), Some(DatabaseType::PostgreSQL));
        assert_eq!(DatabaseType::from_str("sqlite"), Some(DatabaseType::SQLite));
        assert_eq!(DatabaseType::from_str("memory"), Some(DatabaseType::SQLiteMemory));
        assert_eq!(DatabaseType::from_str("sqlite-memory"), Some(DatabaseType::SQLiteMemory));
        assert_eq!(DatabaseType::from_str("invalid"), None);
    }

    #[test]
    fn test_database_config_memory_check() {
        let config = DatabaseConfig {
            db_type: DatabaseType::SQLiteMemory,
            url: "sqlite::memory:".to_string(),
            auto_fallback: true,
        };
        assert!(config.is_memory_database());

        let config = DatabaseConfig {
            db_type: DatabaseType::PostgreSQL,
            url: "postgres://localhost/test".to_string(),
            auto_fallback: false,
        };
        assert!(!config.is_memory_database());
    }
}