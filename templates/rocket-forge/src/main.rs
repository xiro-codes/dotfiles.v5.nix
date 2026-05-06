use app::{
    controllers::index,
    create_base_rocket_with_database,
    database::DatabaseConfig,
    template_config,
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
    let db_config = DatabaseConfig::default();
    log::info!("Database configuration: {:?}", db_config);

    // Build the base rocket instance with database auto-detection
    log::info!("Building Rocket instance and configuring database...");
    let rocket = create_base_rocket_with_database(db_config)
        .await
        .register("/", catchers![catch_default, catch_unauthorized])
        .attach(template_config::create_template_fairing())
        .attach(CORS);

    log::info!("Attaching controllers and static file server");

    rocket
        .mount("/", rocket::routes![index::index])
        .mount("/static", FileServer::from("./static/"))
}
