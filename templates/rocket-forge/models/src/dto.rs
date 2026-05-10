//! Data Transfer Objects and Form structures for the application.

use rocket::serde::{Deserialize, Serialize};
use rocket::FromForm;
use sea_orm::{DerivePartialModel, FromQueryResult};

/// Form DTO for account authentication and registration
#[derive(
    Clone,
    Debug,
    PartialEq,
    DerivePartialModel,
    FromQueryResult,
    Eq,
    Serialize,
    Deserialize,
    FromForm,
)]
#[serde(crate = "rocket::serde")]
#[sea_orm(entity = "super::account::Entity")]
pub struct AccountFormDTO {
    pub username: String,
    pub password: String,
}

/// Form DTO for admin account creation with email
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize, FromForm)]
#[serde(crate = "rocket::serde")]
pub struct AdminCreateFormDTO {
    pub username: String,
    pub password: String,
    pub email: String,
}
