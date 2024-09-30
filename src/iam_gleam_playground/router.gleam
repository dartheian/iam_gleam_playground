import gleam/dynamic.{type Dynamic}
import gleam/http
import iam_gleam_playground/data.{type Data}
import iam_gleam_playground/web.{type Context}
import radish
import radish/error as radish_error
import wisp.{type Request, type Response}

const timeout = 128

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
  case radish.get(context.redis_client, key, timeout) {
    Ok(data) -> wisp.ok() |> wisp.string_body(data)
    Error(radish_error.NotFound) -> wisp.not_found()
    Error(_) -> wisp.internal_server_error()
  }
}

fn put(request: Request, context: Context, key: String) -> Response {
  use <- wisp.require_method(request, http.Put)
  use json <- wisp.require_json(request)
  use data <- decode_data(json)
  case radish.set(context.redis_client, key, data.content, timeout) {
    Ok(_) -> wisp.ok()
    Error(_) -> wisp.internal_server_error()
  }
}

fn decode_data(json: Dynamic, next: fn(Data) -> Response) -> Response {
  case data.decode(json) {
    Ok(data) -> next(data)
    Error(_) -> wisp.unprocessable_entity()
  }
}
