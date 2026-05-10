use crate::pool::Db;
use models::{
    account,
    prelude::Account,
};
use pwhash::bcrypt;
use rocket::{
    fairing::{self, Fairing, Kind},
    Build, Orbit, Rocket,
};
use sea_orm::*;
use sea_orm_rocket::Database;

pub struct Seeding {
    seed: Option<u32>,
}

impl Seeding {
    pub fn new(seed: Option<u32>) -> Self {
        Self { seed }
    }
}

#[rocket::async_trait]
impl Fairing for Seeding {
    fn info(&self) -> fairing::Info {
        fairing::Info {
            name: "Seeding",
            kind: Kind::Ignite | Kind::Shutdown,
        }
    }

    async fn on_ignite(&self, rocket: Rocket<Build>) -> fairing::Result {
        log::info!("Seeding middleware: checking if database seeding is needed");
        let conn = &Db::fetch(&rocket).unwrap().conn;
        
        // Check if data already exists - only seed if database is empty
        let account_count = Account::find().count(conn).await.unwrap_or(0);
        if account_count > 0 {
            log::info!("Database already contains {} accounts, skipping seeding", account_count);
            return Ok(rocket);
        }
        
        log::info!("Database is empty, creating initial admin account...");
        
        log::debug!("Creating admin account");
        let admin_username = std::env::var("DEFAULT_ADMIN_USERNAME").unwrap_or_else(|_| "admin".to_owned());
        let admin_password = std::env::var("DEFAULT_ADMIN_PASSWORD").unwrap_or_else(|_| "pass".to_owned());
        let pw = bcrypt::hash(admin_password).unwrap();
        
        let ac = account::ActiveModel {
            id: Set(uuid::Uuid::new_v4()),
            username: Set(admin_username),
            password: Set(pw),
            email: Set("admin@example.com".to_owned()),
            admin: Set(true),
        }
        .insert(conn)
        .await
        .map_err(|e| {
            log::error!("Failed to seed admin account: {}", e);
            e
        })
        .expect("Failed to seed account.");
        
        log::info!("Admin account created: {} ({})", ac.username, ac.id);

        Ok(rocket)
    }

    async fn on_shutdown(&self, _rocket: &Rocket<Orbit>) {
        log::info!("Application shutting down - preserving database data");
    }
}
