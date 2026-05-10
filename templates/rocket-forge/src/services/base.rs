use sea_orm::*;
use std::future::Future;
use uuid::Uuid;

/// Generic trait for CRUD operations on entities
pub trait CrudService<T, CreateDto, UpdateDto>
where
    T: EntityTrait + Send + Sync,
    T::Model: Send + Sync,
{
    /// Create a new entity
    fn create(
        &self,
        db: &DbConn,
        data: CreateDto,
    ) -> impl Future<Output = Result<T::Model, DbErr>> + Send;

    /// Find an entity by its ID
    fn find_by_id(
        &self,
        db: &DbConn,
        id: Uuid,
    ) -> impl Future<Output = Result<Option<T::Model>, DbErr>> + Send;

    /// Update an entity by its ID
    fn update_by_id(
        &self,
        db: &DbConn,
        id: Uuid,
        data: UpdateDto,
    ) -> impl Future<Output = Result<T::Model, DbErr>> + Send;

    /// Delete an entity by its ID
    fn delete_by_id(
        &self,
        db: &DbConn,
        id: Uuid,
    ) -> impl Future<Output = Result<DeleteResult, DbErr>> + Send;
}

/// Trait for services that can be managed by Rocket
pub trait ManagedService: Send + Sync + 'static {
    /// Create a new instance of the service
    fn new() -> Self;
}

/// Trait for services that have common business logic patterns
pub trait ServiceHelpers {
    /// Generate a new UUID for entities
    fn generate_id() -> Uuid {
        Uuid::new_v4()
    }

    /// Handle common database errors with context
    fn handle_not_found<T>(result: Option<T>, entity_name: &str) -> Result<T, DbErr> {
        result.ok_or_else(|| DbErr::RecordNotFound(format!("{} not found", entity_name)))
    }

    /// Convert database errors to appropriate HTTP status codes
    fn db_error_to_status(err: &DbErr) -> rocket::http::Status {
        use rocket::http::Status;
        match err {
            DbErr::RecordNotFound(_) => Status::NotFound,
            DbErr::Custom(msg) if msg.contains("constraint") => Status::Conflict,
            _ => Status::InternalServerError,
        }
    }
}

/// Base service struct that provides common functionality
pub struct BaseService;

impl BaseService {
    pub fn new() -> Self {
        Self
    }

    /// Generate a new UUID (backward compatibility)
    pub fn generate_id() -> Uuid {
        <Self as ServiceHelpers>::generate_id()
    }

    /// Handle common database errors (backward compatibility)
    pub fn handle_not_found<T>(result: Option<T>, entity_name: &str) -> Result<T, DbErr> {
        <Self as ServiceHelpers>::handle_not_found(result, entity_name)
    }
}

impl ServiceHelpers for BaseService {}

impl ManagedService for BaseService {
    fn new() -> Self {
        Self
    }
}

/// Macro to implement common service patterns
#[macro_export]
macro_rules! impl_service {
    ($service:ty) => {
        impl $crate::services::base::ManagedService for $service {
            fn new() -> Self {
                Self::new()
            }
        }
        
        impl $crate::services::base::ServiceHelpers for $service {}
    };
}

/// Macro to create a service registry from a list of services
#[macro_export]
macro_rules! create_service_registry {
    ($registry_name:ident, [ $( $service:ty ),* $(,)? ]) => {
        pub struct $registry_name;
        
        impl $registry_name {
            pub fn attach_all_services(rocket: rocket::Rocket<rocket::Build>) -> rocket::Rocket<rocket::Build> {
                log::info!("Registering {} services...", stringify!($registry_name));
                
                rocket$(
                    .manage(<$service>::new())
                )*
            }
            
            pub fn fairing() -> rocket::fairing::AdHoc {
                rocket::fairing::AdHoc::on_ignite(stringify!($registry_name), |rocket| async {
                    Self::attach_all_services(rocket)
                })
            }
        }
    };
}

/// Macro to reduce boilerplate in service constructors with base field
#[macro_export]
macro_rules! impl_service_with_base {
    ($service:ty) => {
        impl $service {
            pub fn new() -> Self {
                Self {
                    base: $crate::services::base::BaseService::new(),
                }
            }
        }
        
        $crate::impl_service!($service);
    };
}

/// Macro for services with custom constructors
#[macro_export]
macro_rules! impl_service_custom {
    ($service:ty) => {
        $crate::impl_service!($service);
    };
}
