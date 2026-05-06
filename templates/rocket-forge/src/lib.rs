//! # Rocket Blog Application Library
//!
//! A modern, fast, and feature-rich blog application built with **Rust** and the **Rocket** web framework.
//! This library serves as the shared foundation for both the blog and work time tracker binaries.
//!
//! ## Overview
//!
//! This crate provides a complete web application framework with:
//! - **Blog Management**: Create, edit, delete, and publish blog posts with markdown support
//! - **Authentication System**: Secure login/logout with admin privileges
//! - **Comment System**: Reader engagement with moderation capabilities
//! - **Media Support**: Video streaming with range requests
//! - **Database Integration**: PostgreSQL with SeaORM for type-safe queries
//! - **Template Engine**: Server-side rendering with Tera templates
//!
//! ## Architecture
//!
//! The application follows a modular architecture with clear separation of concerns:
//! - **Controllers**: Handle HTTP requests and responses
//! - **Services**: Contain business logic and database operations
//! - **Models**: Type-safe database entities
//! - **Middleware**: Handle authentication, seeding, and request processing
//! - **Guards**: Route protection and access control
//!
//! ## Usage
//!
//! ```rust,no_run
//! use app::{create_base_rocket, setup_logger};
//!
//! #[tokio::main]
//! async fn main() {
//!     // Setup logging
//!     setup_logger().expect("Failed to setup logger");
//!     
//!     // Create and launch the rocket instance
//!     let rocket = create_base_rocket();
//!     // Add your specific routes and launch...
//! }
//! ```
//!
//! ## Features
//!
//! - **Type Safety**: Leverages Rust's type system for safe database operations
//! - **Performance**: Async/await throughout with efficient request handling
//! - **Security**: Built-in authentication, CSRF protection, and input validation
//! - **Scalability**: Modular design supporting multiple deployment configurations
//!
//! ## Configuration
//!
//! Configuration is handled through Rocket's Figment system. See [`config`] module for details.

#[macro_use]
extern crate rocket;

/// Application configuration and settings management
pub mod config;

/// Database configuration and auto-fallback functionality
pub mod database;

/// HTTP route handlers and request/response processing
pub mod controllers;

/// Database connection pool management
pub mod pool;

/// Template configuration with custom filters
pub mod template_config;

#[cfg(test)]
pub mod tests;

use config::AppConfig;
use database::DatabaseConfig;
use migrations::MigratorTrait;
use pool::Db;
use rocket::{fairing, fairing::AdHoc, Build, Rocket};
use sea_orm_rocket::Database;
use std::time::SystemTime;

/// Runs database migrations on application startup.
///
/// This function is called during Rocket's ignition phase to ensure the database
/// schema is up to date before the application starts handling requests.
///
/// # Arguments
///
/// * `rocket` - The Rocket instance being built
///
/// # Returns
///
/// Returns `Ok(rocket)` on successful migration, or logs errors and continues
/// with the rocket instance if migrations fail.
///
/// # Examples
///
/// This function is typically used as a fairing:
///
/// ```rust,no_run
/// use rocket::fairing::AdHoc;
/// use app::run_migrations;
///
/// let rocket = rocket::build()
///     .attach(AdHoc::try_on_ignite("Migrations", run_migrations));
/// ```
pub async fn run_migrations(rocket: Rocket<Build>) -> fairing::Result {
    log::info!("Starting database migrations...");
    let conn = &Db::fetch(&rocket).unwrap().conn;
    
    match migrations::Migrator::up(conn, None).await {
        Ok(_) => {
            log::info!("Database migrations completed successfully");
        }
        Err(e) => {
            log::error!("Database migration failed: {}", e);
        }
    }
    
    Ok(rocket)
}

/// Filters out noisy log messages from dependencies.
///
/// This function is used to reduce log verbosity by filtering out messages
/// from known noisy dependencies like Rocket, SeaORM, SQLx, etc.
///
/// # Arguments
///
/// * `meta` - Log metadata containing the target information
///
/// # Returns
///
/// Returns `true` if the log should be filtered out, `false` otherwise.
fn should_filter_log(meta: &log::Metadata) -> bool {
    let target = meta.target();
    // Filter out noisy log targets
    target.starts_with("rocket") || 
    target.starts_with("sea_orm_migration") || 
    target.starts_with("sqlx") || 
    target.starts_with("hyper") || 
    target.eq("_")
}

/// Sets up application logging with clean filtering and appropriate output channels.
///
/// Configures the logging system with:
/// - RFC3339 timestamp formatting
/// - Configurable log levels based on features
/// - Filtering of noisy dependency logs
/// - File output to `output.log`
/// - Console output in development mode
///
/// # Returns
///
/// Returns `Ok(())` on successful setup, or a `fern::InitError` if logging
/// could not be initialized.
///
/// # Examples
///
/// ```rust,no_run
/// use app::setup_logger;
///
/// setup_logger().expect("Failed to setup logger");
/// ```
///
/// # Errors
///
/// This function will return an error if:
/// - The log file cannot be created or written to
/// - The logging system has already been initialized
pub fn setup_logger() -> Result<(), fern::InitError> {
    let mut dispatch = fern::Dispatch::new()
        .format(|out, message, record| {
            out.finish(format_args!(
                "[{} {} {}] {}",
                humantime::format_rfc3339_seconds(SystemTime::now()),
                record.level(),
                record.target(),
                message
            ))
        })
        .level(log::LevelFilter::Info)
        .filter(|meta| !should_filter_log(meta))
        .chain(fern::log_file("output.log")?);
    
    // In development mode, also log to stdout for real-time feedback
    if cfg!(debug_assertions) {
        dispatch = dispatch.chain(std::io::stdout());
    }
    
    dispatch.apply()?;
    Ok(())
}

/// Creates a base Rocket instance with common configuration and services.
///
/// This function provides a pre-configured Rocket instance with:
/// - Database connection pool initialization
/// - Database migration setup
/// - Application configuration management
/// - Base middleware and fairings
///
/// This serves as the foundation for both the blog and worktime binaries,
/// allowing them to add their specific routes and configurations on top.
///
/// # Returns
///
/// Returns a configured `Rocket<Build>` instance ready for route attachment
/// and launching.
///
/// # Examples
///
/// ```rust,no_run
/// use app::create_base_rocket;
/// use rocket::routes;
///
/// let rocket = create_base_rocket()
///     .mount("/api", routes![/* your routes */]);
/// ```
pub fn create_base_rocket() -> Rocket<Build> {
    let figment = rocket::Config::figment();
    let app_config = AppConfig::from_figment(&figment);
    
    // Setup logging - ignore errors if already initialized
    // let _ = setup_logger();
    
    // Build the base rocket instance with common components
    let rocket = rocket::build()
        .attach(Db::init())
        .attach(AdHoc::try_on_ignite("Migrations", run_migrations))
        .manage(app_config);
    
    rocket
}

/// Creates a base Rocket instance with dynamic database configuration.
///
/// This function provides the same pre-configured Rocket instance as `create_base_rocket`,
/// but allows for dynamic database configuration including auto-fallback functionality.
///
/// # Arguments
///
/// * `db_config` - Database configuration including fallback options
///
/// # Returns
///
/// Returns a configured `Rocket<Build>` instance ready for route attachment
/// and launching, or panics if database connection fails.
///
/// # Examples
///
/// ```rust,no_run
/// use app::{create_base_rocket_with_database, database::DatabaseConfig};
///
/// let db_config = DatabaseConfig::default_with_fallback();
/// let rocket = create_base_rocket_with_database(db_config);
/// ```
pub async fn create_base_rocket_with_database(mut db_config: DatabaseConfig) -> Rocket<Build> {
    let figment = rocket::Config::figment();
    let app_config = AppConfig::from_figment(&figment);
    
    // Test database connection and handle fallback
    match db_config.test_and_select_database().await {
        Ok(_backend) => {
            log::info!("Using {} database", db_config.db_type.display_name());
            if db_config.is_memory_database() {
                log::warn!("⚠️  Using in-memory database - data will not persist between restarts!");
            }
        }
        Err(e) => {
            log::error!("Database configuration failed: {}", e);
            panic!("Failed to establish database connection: {}", e);
        }
    }
    
    // Create a custom Rocket configuration with the selected database URL
    let db_url = db_config.get_url().to_string();
    let figment = rocket::Config::figment()
        .merge(("databases.sea_orm.url", db_url));
    
    // Build the rocket instance with custom database configuration
    let rocket = rocket::custom(figment)
        .attach(Db::init())
        .attach(AdHoc::try_on_ignite("Migrations", run_migrations))
        .manage(app_config)
        .manage(db_config);
    
    rocket
}
