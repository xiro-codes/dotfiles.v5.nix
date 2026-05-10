//! Application middleware for request/response processing.
//!
//! This module contains middleware components that handle cross-cutting concerns
//! like database seeding, request logging, and other application lifecycle hooks.
//!
//! ## Available Middleware
//!
//! - [`Seeding`] - Database seeding and test data management
//!
//! ## Usage
//!
//! Middleware is typically attached as fairings to the Rocket instance:
//!
//! ```rust,no_run
//! use rocket::build;
//! use app::middleware::Seeding;
//!
//! let rocket = rocket::build()
//!     .attach(Seeding::new(Some(0), 50));
//! ```

mod seeding;
/// Database seeding middleware for development and testing
pub use seeding::Seeding;
