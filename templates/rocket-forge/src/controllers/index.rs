use rocket::{http::CookieJar, State, Route, routes, get};
use rocket_dyn_templates::{context, Template};
use sea_orm_rocket::Connection;
use crate::{
    controllers::base::ControllerBase,
    pool::Db,
    services::AuthService,
};
use uuid::Uuid;

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
pub async fn index(
    jar: &CookieJar<'_>,
    conn: Connection<'_, Db>,
    auth_service: &State<AuthService>,
) -> Template {
    let db = conn.into_inner();
    let mut username = None;

    if let Some(token_str) = jar.get_private("token") {
        if let Ok(token_uuid) = Uuid::parse_str(token_str.value()) {
            if let Some(user) = auth_service.check_token(db, token_uuid).await {
                username = Some(user.username);
            }
        }
    }

    Template::render("index", context! {
        title: "Home",
        username: username,
    })
}

fn routes() -> Vec<Route> {
    routes![index]
}

crate::impl_controller_routes!(Controller, "Index Controller", routes());
