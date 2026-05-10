use app::{
    controllers::{index, auth},
    create_base_rocket_with_database,
    database::DatabaseConfig,
    template_config,
    services::AuthService,
};
use rocket::{
    catch, catchers,
    fairing::{Fairing, Info, Kind},
    fs::FileServer,
    http::Header,
    launch,
    response::Redirect,
    Build, Request, Response, Rocket,
};

#[catch(default)]
pub fn catch_default() -> Redirect {
    log::warn!("Unhandled route accessed - redirecting to home page");
    Redirect::to("/")
}

#[catch(401)]
pub fn catch_unauthorized() -> Redirect {
    log::info!("Unauthorized access detected - redirecting to home");
    Redirect::to("/")
}

/// CORS fairing for PWA functionality
pub struct CORS;

#[rocket::async_trait]
impl Fairing for CORS {
    fn info(&self) -> Info {
        Info {
            name: "Add CORS headers",
            kind: Kind::Response,
        }
    }

    async fn on_response<'r>(&self, _request: &'r Request<'_>, response: &mut Response<'r>) {
        response.set_header(Header::new("Access-Control-Allow-Origin", "*"));
        response.set_header(Header::new(
            "Access-Control-Allow-Methods",
            "POST, GET, PATCH, OPTIONS",
        ));
        response.set_header(Header::new("Access-Control-Allow-Headers", "*"));
        response.set_header(Header::new("Access-Control-Allow-Credentials", "true"));
    }
}

#[launch]
async fn rocket() -> Rocket<Build> {
    log::info!("Starting Rocket Web Application...");

    // Basic database configuration setup
    let db_config = DatabaseConfig::default_with_fallback();
    log::info!("Database configuration: {:?}", db_config);

    // Build the base rocket instance with database auto-detection
    log::info!("Building Rocket instance and configuring database...");
    let mut rocket = create_base_rocket_with_database(db_config)
        .await
        .register("/", catchers![catch_default, catch_unauthorized])
        .attach(template_config::create_template_fairing())
        .attach(app::middleware::Seeding::new(None))
        .attach(CORS);

    rocket = rocket.manage(AuthService::new());

    log::info!("Attaching controllers and static file server");

    rocket
        .attach(index::Controller::new("/".to_owned()))
        .attach(auth::Controller::new("/auth".to_owned()))
        .mount("/static", FileServer::from("./static/"))
}
