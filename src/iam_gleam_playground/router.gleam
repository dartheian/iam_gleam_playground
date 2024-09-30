import gleam/http
import iam_gleam_playground/middleware
import iam_gleam_playground/web.{type Context}
import wisp.{type Request, type Response}

pub fn handle_request(request: Request, context: Context) -> Response {
  use request <- web.middleware(request)
  case wisp.path_segments(request) {
    ["health-check"] -> health_check(request)
    [key] -> redis(request, context, key)
    _ -> wisp.not_found()
  }
}

fn health_check(request: Request) -> Response {
  use <- wisp.require_method(request, http.Get)
  wisp.ok()
}

fn redis(request: Request, context: Context, key) -> Response {
  case request.method {
    http.Get -> get(request, context, key)
    http.Put -> put(request, context, key)
    _ -> wisp.method_not_allowed(allowed: [http.Get, http.Put])
  }
}

fn get(request: Request, context: Context, key: String) -> Response {
  use <- wisp.require_method(request, http.Get)
  use data <- middleware.get_session(context, key)
  wisp.ok()
  |> wisp.string_body(data)
}

fn put(request: Request, context: Context, key: String) -> Response {
  use <- wisp.require_method(request, http.Put)
  use json <- wisp.require_json(request)
  use data <- middleware.decode_data(json)
  use <- middleware.set_session(context, key, data.content)
  wisp.ok()
}
