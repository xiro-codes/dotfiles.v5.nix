#![allow(unused_imports)]
use rocket::{
    http::{CookieJar, Status},
    request::FlashMessage,
    response::{Flash, Redirect},
    Build, Rocket,
    fairing::{self, Fairing, Kind},
};

/// Trait for common controller behaviors
pub trait ControllerHelpers {
    /// Check if user is authenticated and return token
    fn check_auth(jar: &CookieJar<'_>) -> Result<Option<String>, Status> {
        Ok(jar.get_private("token").map(|c| c.value().to_owned()))
    }

    /// Require authentication and return token, or return Unauthorized status
    fn require_auth(jar: &CookieJar<'_>) -> Result<String, Status> {
        Self::check_auth(jar)?.ok_or(Status::Unauthorized)
    }

    /// Create a success flash redirect
    fn success_redirect<T: Into<String>, U: Into<String>>(
        to: T,
        message: U,
    ) -> Flash<Redirect> {
        Flash::success(Redirect::to(to.into()), message.into())
    }

    /// Create a danger flash redirect
    fn danger_redirect<T: Into<String>, U: Into<String>>(to: T, message: U) -> Flash<Redirect> {
        Flash::new(Redirect::to(to.into()), "danger", message.into())
    }

    /// Extract flash message content for template context
    fn extract_flash(flash: Option<FlashMessage<'_>>) -> Option<(String, String)> {
        flash.map(|f| {
            let (kind, message) = f.into_inner();
            (kind.to_string(), message)
        })
    }
}

/// Trait for controllers that can be mounted to a Rocket instance
pub trait MountableController {
    fn path(&self) -> &str;
    fn name(&self) -> &'static str;
}

/// Common controller functionality
pub struct ControllerBase {
    path: String,
}

impl ControllerBase {
    pub fn new(path: String) -> Self {
        Self { path }
    }

    pub fn path(&self) -> &str {
        &self.path
    }

    /// Check if user is authenticated and return token (backward compatibility)
    pub fn check_auth(jar: &CookieJar<'_>) -> Result<Option<String>, Status> {
        <Self as ControllerHelpers>::check_auth(jar)
    }

    /// Require authentication and return token, or return Unauthorized status (backward compatibility)
    pub fn require_auth(jar: &CookieJar<'_>) -> Result<String, Status> {
        <Self as ControllerHelpers>::require_auth(jar)
    }

    /// Create a success flash redirect (backward compatibility)
    pub fn success_redirect<T: Into<String>, U: Into<String>>(
        to: T,
        message: U,
    ) -> Flash<Redirect> {
        <Self as ControllerHelpers>::success_redirect(to, message)
    }

    /// Create a danger flash redirect (backward compatibility)
    pub fn danger_redirect<T: Into<String>, U: Into<String>>(to: T, message: U) -> Flash<Redirect> {
        <Self as ControllerHelpers>::danger_redirect(to, message)
    }

    /// Extract flash message content for template context (backward compatibility)
    pub fn extract_flash(flash: Option<FlashMessage<'_>>) -> Option<(String, String)> {
        <Self as ControllerHelpers>::extract_flash(flash)
    }
}

impl ControllerHelpers for ControllerBase {}

/// Macro to implement Fairing for controllers with a service (deprecated - use impl_controller_routes!)
#[macro_export]
macro_rules! impl_controller_fairing {
    ($controller:ty, $service:ty, $name:expr, $routes:expr) => {
        #[rocket::async_trait]
        impl rocket::fairing::Fairing for $controller {
            fn info(&self) -> rocket::fairing::Info {
                rocket::fairing::Info {
                    name: $name,
                    kind: rocket::fairing::Kind::Ignite,
                }
            }

            async fn on_ignite(&self, rocket: rocket::Rocket<rocket::Build>) -> rocket::fairing::Result {
                Ok(rocket
                    .manage(<$service>::new())
                    .mount(self.base.path(), $routes))
            }
        }
    };
}

/// Macro to implement Fairing for controllers that only mount routes (services managed by ServiceRegistry)
#[macro_export]
macro_rules! impl_controller_routes {
    ($controller:ty, $name:expr, $routes:expr) => {
        #[rocket::async_trait]
        impl rocket::fairing::Fairing for $controller {
            fn info(&self) -> rocket::fairing::Info {
                rocket::fairing::Info {
                    name: $name,
                    kind: rocket::fairing::Kind::Ignite,
                }
            }

            async fn on_ignite(&self, rocket: rocket::Rocket<rocket::Build>) -> rocket::fairing::Result {
                Ok(rocket.mount(self.base.path(), $routes))
            }
        }
    };
}

/// Enhanced macro to implement a complete controller with traits
#[macro_export]
macro_rules! impl_controller {
    ($controller:ty, $name:expr, $routes:expr) => {
        impl $crate::controllers::base::MountableController for $controller {
            fn path(&self) -> &str {
                self.base.path()
            }
            
            fn name(&self) -> &'static str {
                $name
            }
        }
        
        impl $crate::controllers::base::ControllerHelpers for $controller {}
        
        #[rocket::async_trait]
        impl rocket::fairing::Fairing for $controller {
            fn info(&self) -> rocket::fairing::Info {
                rocket::fairing::Info {
                    name: $name,
                    kind: rocket::fairing::Kind::Ignite,
                }
            }

            async fn on_ignite(&self, rocket: rocket::Rocket<rocket::Build>) -> rocket::fairing::Result {
                Ok(rocket.mount(self.base.path(), $routes))
            }
        }
    };
}

/// Macro to create a controller registry from a list of controllers
#[macro_export]
macro_rules! create_controller_registry {
    ($registry_name:ident, [ $( ($controller:ty, $path:expr) ),* $(,)? ]) => {
        pub struct $registry_name;
        
        impl $registry_name {
            pub fn attach_all_controllers(rocket: rocket::Rocket<rocket::Build>) -> rocket::Rocket<rocket::Build> {
                log::info!("Registering {} controllers...", stringify!($registry_name));
                
                rocket$(
                    .attach(<$controller>::new($path.to_owned()))
                )*
            }
            
            pub fn fairing() -> rocket::fairing::AdHoc {
                rocket::fairing::AdHoc::on_ignite(stringify!($registry_name), |rocket| async {
                    Self::attach_all_controllers(rocket)
                })
            }
        }
    };
}

/// Macro for common auth-required endpoint patterns
#[macro_export]
macro_rules! auth_required {
    ($jar:expr) => {
        match <$crate::controllers::base::ControllerBase as $crate::controllers::base::ControllerHelpers>::require_auth($jar) {
            Ok(token) => token,
            Err(status) => return Err(status),
        }
    };
}
