use models::dto::{AccountFormDTO, AdminCreateFormDTO};
use rocket::{
    fairing::{self, Fairing, Kind},
    form::Form,
    http::{Cookie, CookieJar, Status},
    response::{Flash, Redirect},
    Build, Rocket, Route, State,
};
use rocket_dyn_templates::{context, Template};
use sea_orm_rocket::Connection;

use crate::{
    controllers::base::ControllerBase,
    pool::Db,
    services::AuthService,
};

/// This Controller also provides the AuthService
pub struct Controller {
    base: ControllerBase,
}

impl Controller {
    pub fn new(path: String) -> Self {
        Self {
            base: ControllerBase::new(path),
        }
    }
}

#[get("/")]
async fn login_view(
    conn: Connection<'_, Db>,
    service: &State<AuthService>,
) -> Result<Template, Status> {
    log::info!("Route accessed: GET /auth/ - Login page requested");
    let db = conn.into_inner();
    
    // Check if any accounts exist, return 404 if none
    if !service.has_any_accounts(db).await {
        log::info!("No accounts exist in system - login page not available");
        return Err(Status::NotFound);
    }
    
    log::debug!("Login page served successfully");
    Ok(Template::render(
        "auth/login",
        context! {}
    ))
}

#[post("/", data = "<data>")]
async fn login(
    conn: Connection<'_, Db>,
    service: &State<AuthService>,
    jar: &CookieJar<'_>,
    data: Form<AccountFormDTO>,
) -> Flash<Redirect> {
    let form_data = data.into_inner();
    log::info!("Route accessed: POST /auth/ - Login attempt for username: {}", form_data.username);
    
    let db = conn.into_inner();
    if let Ok(token) = service.login(db, form_data).await {
        let mut cookie = Cookie::new("token", token.to_string());
        cookie.set_path("/");
        jar.add_private(cookie);
        log::info!("Login successful - redirecting to blog");
        ControllerBase::success_redirect("/", "Login successful.")
    } else {
        log::warn!("Login failed - redirecting back to login form");
        ControllerBase::danger_redirect("/auth/", "Login failed.")
    }
}

#[get("/logout")]
async fn logout(jar: &CookieJar<'_>) -> Flash<Redirect> {
    log::info!("Route accessed: GET /auth/logout - User logout requested");
    let mut cookie = Cookie::from("token");
    cookie.set_path("/");
    jar.remove_private(cookie);
    log::info!("User logged out successfully");
    ControllerBase::success_redirect("/", "Logout successful.")
}

#[get("/create-admin")]
async fn create_admin_view(
    conn: Connection<'_, Db>,
    service: &State<AuthService>,
) -> Result<Template, Status> {
    log::info!("Route accessed: GET /auth/create-admin - Create admin page requested");
    let db = conn.into_inner();
    
    // Check if any accounts exist, redirect if they do
    if service.has_any_accounts(db).await {
        log::info!("Admin creation blocked - accounts already exist");
        return Err(Status::NotFound);
    }
    
    log::debug!("Create admin page served successfully");
    Ok(Template::render(
        "auth/create_admin",
        context! {}
    ))
}

#[post("/create-admin", data = "<data>")]
async fn create_admin(
    conn: Connection<'_, Db>,
    service: &State<AuthService>,
    _jar: &CookieJar<'_>,
    data: Form<AdminCreateFormDTO>,
) -> Flash<Redirect> {
    let form_data = data.into_inner();
    log::info!("Route accessed: POST /auth/create-admin - Admin account creation attempt for username: {}", form_data.username);
    
    let db = conn.into_inner();
    
    match service.create_admin_account(db, form_data).await {
        Ok(account) => {
            log::info!("Admin account creation successful for: {} ({})", account.username, account.id);
            ControllerBase::success_redirect("/", "Admin account created successfully! You can now log in.")
        }
        Err(e) => {
            log::error!("Admin account creation failed: {}", e);
            ControllerBase::danger_redirect("/auth/create-admin", "Failed to create admin account. It may already exist.")
        }
    }
}

#[get("/register")]
async fn register_view() -> Template {
    log::info!("Route accessed: GET /auth/register - User registration page requested");
    Template::render(
        "auth/register",
        context! {}
    )
}

#[post("/register", data = "<data>")]
async fn register(
    conn: Connection<'_, Db>,
    service: &State<AuthService>,
    _jar: &CookieJar<'_>,
    data: Form<AccountFormDTO>,
) -> Flash<Redirect> {
    let form_data = data.into_inner();
    log::info!("Route accessed: POST /auth/register - User account registration attempt for username: {}", form_data.username);
    
    let db = conn.into_inner();
    
    match service.create_user_account(db, form_data).await {
        Ok(account) => {
            log::info!("User account registration successful for: {} ({})", account.username, account.id);
            ControllerBase::success_redirect("/auth", "Account created successfully! You can now log in.")
        }
        Err(e) => {
            log::error!("User account registration failed: {}", e);
            ControllerBase::danger_redirect("/auth/register", "Failed to create account. Username may already exist.")
        }
    }
}

fn routes() -> Vec<Route> {
    routes![login_view, login, logout, create_admin_view, create_admin, register_view, register]
}

crate::impl_controller_routes!(Controller, "Auth Controller", routes());
