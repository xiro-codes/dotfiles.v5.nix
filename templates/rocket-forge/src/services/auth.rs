use std::collections::HashMap;

use models::{account, dto::{AccountFormDTO, AdminCreateFormDTO}};
use pwhash::bcrypt;
use rocket::futures::lock::Mutex;
use sea_orm::*;
use uuid::Uuid;
use redis::AsyncCommands;

use crate::{services::base::BaseService, impl_service_custom};

pub struct Service {
    base: BaseService,
    token_map: Mutex<HashMap<Token, AccountId>>,
    redis_client: Option<redis::Client>,
}
type Token = Uuid;
type AccountId = Uuid;

impl Service {
    pub fn new() -> Self {
        let redis_client = redis::Client::open("redis://127.0.0.1/").ok();
        Self {
            base: BaseService::new(),
            token_map: Mutex::new(HashMap::new()),
            redis_client,
        }
    }

    pub async fn login(&self, db: &DbConn, data: AccountFormDTO) -> Result<Token, DbErr> {
        log::debug!("Authentication attempt for username: {}", data.username);
        
        let ac = account::Entity::query()
            .where_eq(account::Column::Username, &data.username)
            .first(db)
            .await
            .unwrap();
            
        if let Some(ac) = ac {
            log::debug!("User found in database: {}", data.username);
            let auth = bcrypt::verify(data.password, &ac.password);
            if !auth {
                log::warn!("Password verification failed for username: {}", data.username);
                return Err(DbErr::Custom("Authentication failed".to_owned()));
            }
            
            let token = {
                let mut tm = self.token_map.lock().await;
                let token = BaseService::generate_id();
                tm.insert(token, ac.id);
                if let Some(client) = &self.redis_client {
                    if let Ok(mut con) = client.get_multiplexed_async_connection().await {
                        let _: Result<(), _> = redis::AsyncCommands::set(&mut con, token.to_string(), ac.id.to_string()).await;
                    }
                }
                log::info!("User successfully authenticated: {} (ID: {})", data.username, ac.id);
                log::debug!("Generated token: {}", token);
                token
            };
            return Ok(token);
        }
        
        log::warn!("Login attempt failed - user not found: {}", data.username);
        Err(DbErr::Custom("User not found".to_owned()))
    }

    pub async fn check_token(&self, db: &DbConn, token: Token) -> Option<account::Model> {
        log::debug!("Checking token validity: {}", token);
        
        let mut id = {
            let tm = self.token_map.lock().await;
            tm.get(&token).cloned()
        };

        if id.is_none() {
            if let Some(client) = &self.redis_client {
                if let Ok(mut con) = client.get_multiplexed_async_connection().await {
                    if let Ok(account_str) = redis::AsyncCommands::get::<_, String>(&mut con, token.to_string()).await {
                        if let Ok(account_uuid) = Uuid::parse_str(&account_str) {
                            id = Some(account_uuid);
                            let mut tm = self.token_map.lock().await;
                            tm.insert(token, account_uuid);
                        }
                    }
                }
            }
        }
        
        if let Some(id) = id {
            log::debug!("Token found in memory, fetching account: {}", id);
            let account = account::Entity::query()
                .where_eq(account::Column::Id, id)
                .first(db)
                .await;
            match &account {
                Ok(Some(acc)) => {
                    log::debug!("Token validated for user: {} ({})", acc.username, acc.id);
                }
                Ok(None) => {
                    log::warn!("Token references non-existent account: {}", id);
                }
                Err(e) => {
                    log::error!("Database error checking token: {}", e);
                }
            }
            return account.unwrap();
        }
        
        log::debug!("Token not found in memory: {}", token);
        None
    }

    pub async fn has_any_accounts(&self, db: &DbConn) -> bool {
        log::debug!("Checking if any accounts exist in database");
        match account::Entity::query().limit(1).first(db).await {
            Ok(Some(_)) => {
                log::debug!("Found existing account(s) in database");
                true
            }
            Ok(None) => {
                log::debug!("No accounts found in database");
                false
            }
            Err(e) => {
                log::error!("Database error checking for accounts: {}", e);
                false
            }
        }
    }

    pub async fn create_admin_account(&self, db: &DbConn, data: AdminCreateFormDTO) -> Result<account::Model, DbErr> {
        log::info!("Attempting to create admin account for username: {}", data.username);
        
        // Check if any accounts exist first
        if self.has_any_accounts(db).await {
            log::warn!("Admin account creation blocked - accounts already exist");
            return Err(DbErr::Custom("Admin account already exists".to_owned()));
        }

        log::debug!("Hashing password for new admin account");
        let pw = bcrypt::hash(&data.password).map_err(|e| {
            log::error!("Password hashing failed: {}", e);
            DbErr::Custom("Password hashing failed".to_owned())
        })?;
        
        let account_id = BaseService::generate_id();
        log::debug!("Creating admin account with ID: {}", account_id);
        
        let account = account::ActiveModel {
            id: Set(account_id),
            username: Set(data.username.clone()),
            password: Set(pw),
            email: Set(data.email.clone()),
            admin: Set(true),
        }
        .insert(db)
        .await
        .map_err(|e| {
            log::error!("Failed to insert admin account: {}", e);
            e
        })?;

        log::info!("Admin account created successfully: {} ({})", data.username, account.id);
        Ok(account)
    }

    /// Create a regular (non-admin) user account
    pub async fn create_user_account(&self, db: &DbConn, data: AccountFormDTO) -> Result<account::Model, DbErr> {
        log::info!("Attempting to create user account for username: {}", data.username);
        
        // Check if username already exists
        let existing_user = account::Entity::query()
            .where_eq(account::Column::Username, &data.username)
            .first(db)
            .await?;
            
        if existing_user.is_some() {
            log::warn!("User account creation blocked - username already exists: {}", data.username);
            return Err(DbErr::Custom("Username already exists".to_owned()));
        }

        log::debug!("Hashing password for new user account");
        let pw = bcrypt::hash(&data.password).map_err(|e| {
            log::error!("Password hashing failed: {}", e);
            DbErr::Custom("Password hashing failed".to_owned())
        })?;
        
        let account_id = BaseService::generate_id();
        log::debug!("Creating user account with ID: {}", account_id);
        
        let account = account::ActiveModel {
            id: Set(account_id),
            username: Set(data.username.clone()),
            password: Set(pw),
            email: Set("".to_string()), // Regular users don't need email
            admin: Set(false),
        }
        .insert(db)
        .await
        .map_err(|e| {
            log::error!("Failed to insert user account: {}", e);
            e
        })?;

        log::info!("User account created successfully: {} ({})", data.username, account.id);
        Ok(account)
    }

    /// Check if a token belongs to an admin user
    pub async fn is_admin_token(&self, db: &DbConn, token_str: &str) -> bool {
        if let Ok(token_uuid) = Uuid::parse_str(token_str) {
            if let Some(account) = self.check_token(db, token_uuid).await {
                return account.admin;
            }
        }
        false
    }

    /// Check if a token is valid and belongs to an admin
    pub async fn require_admin_token(&self, db: &DbConn, token_str: &str) -> Result<account::Model, DbErr> {
        let token_uuid = Uuid::parse_str(token_str)
            .map_err(|_| DbErr::Custom("Invalid token format".to_owned()))?;
        
        if let Some(account) = self.check_token(db, token_uuid).await {
            if account.admin {
                Ok(account)
            } else {
                Err(DbErr::Custom("Admin access required".to_owned()))
            }
        } else {
            Err(DbErr::Custom("Invalid token".to_owned()))
        }
    }
}

impl_service_custom!(Service);
