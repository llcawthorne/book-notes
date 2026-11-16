use actix_web::HttpResponse;
use actix_web::web;

#[derive(serde::Deserialize)]
// Fields are deserialized for validation; persistence is added in a later chapter.
#[allow(dead_code)]
pub struct FormData {
    email: String,
    name: String,
}

pub async fn subscribe(_form: web::Form<FormData>) -> HttpResponse {
    HttpResponse::Ok().finish()
}
