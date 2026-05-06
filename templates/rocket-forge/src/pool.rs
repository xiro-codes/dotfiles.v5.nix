//! Database connection pool management.
//!
//! This module provides database connection pooling using SeaORM with Rocket's
//! database integration. It handles connection lifecycle, pooling configuration,
//! and automatic cleanup.

use sea_orm::ConnectOptions;
use sea_orm_rocket::{rocket::figment::Figment, Config, Database};
use std::time::Duration;

/// Database connection pool wrapper for Rocket integration.
///
/// This struct integrates SeaORM with Rocket's database management system,
/// providing automatic connection pooling and lifecycle management.
#[derive(Database, Debug)]
#[database("sea_orm")]
pub struct Db(SeaOrmPool);

/// SeaORM connection pool implementation.
///
/// Handles the actual database connections with configurable pooling
/// parameters such as connection limits and timeouts.
#[derive(Debug)]
pub struct SeaOrmPool {
    /// The main database connection handle
    pub conn: sea_orm::DatabaseConnection,
}

#[rocket::async_trait]
impl sea_orm_rocket::Pool for SeaOrmPool {
    type Error = sea_orm::DbErr;
    type Connection = sea_orm::DatabaseConnection;

    /// Initializes the connection pool from Rocket configuration.
    ///
    /// Creates a new connection pool using parameters from the Rocket
    /// configuration system, including connection limits, timeouts, and
    /// logging preferences.
    ///
    /// # Arguments
    ///
    /// * `figment` - Rocket's configuration provider
    ///
    /// # Returns
    ///
    /// Returns a configured `SeaOrmPool` or a database error if connection fails.
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - Database connection cannot be established
    /// - Configuration parameters are invalid
    /// - Database server is unreachable
    async fn init(figment: &Figment) -> Result<Self, Self::Error> {
        let config = figment.extract::<Config>().unwrap();
        let mut options: ConnectOptions = config.url.into();
        options
            .max_connections(config.max_connections as u32)
            .min_connections(config.min_connections.unwrap_or_default())
            .connect_timeout(Duration::from_secs(config.connect_timeout))
            .sqlx_logging(config.sqlx_logging);
        if let Some(idle_timeout) = config.idle_timeout {
            options.idle_timeout(Duration::from_secs(idle_timeout));
        }
        let conn = sea_orm::Database::connect(options).await?;

        Ok(SeaOrmPool { conn })
    }

    /// Borrows a connection from the pool.
    ///
    /// Returns a reference to the database connection for executing queries.
    /// The connection is automatically returned to the pool when the reference
    /// is dropped.
    ///
    /// # Returns
    ///
    /// Returns a reference to the database connection.
    fn borrow(&self) -> &Self::Connection {
        &self.conn
    }
}
