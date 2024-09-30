import gleam/dynamic.{type Dynamic}
import iam_gleam_playground/data.{type Data}
import iam_gleam_playground/web.{type Context}
import radish
import radish/error as radish_error
import wisp.{type Response}

const timeout = 128

pub fn decode_data(json: Dynamic, next: fn(Data) -> Response) -> Response {
  case data.decode(json) {
    Ok(data) -> next(data)
    Error(_) -> wisp.unprocessable_entity()
  }
}

pub fn set_session(
  context: Context,
  key: String,
  value: String,
  next: fn() -> Response,
) -> Response {
  case radish.set(context.redis_client, key, value, timeout) {
    Ok(_) -> next()
    Error(_) -> wisp.internal_server_error()
  }
}

pub fn get_session(
  context: Context,
  key: String,
  next: fn(String) -> Response,
) -> Response {
  case radish.get(context.redis_client, key, timeout) {
    Ok(value) -> next(value)
    Error(radish_error.NotFound) -> wisp.not_found()
    Error(_) -> wisp.internal_server_error()
  }
}
