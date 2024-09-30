import gleam/erlang/process.{type Subject}
import radish.{type Message}
import wisp

pub type Context {
  Context(redis_client: Subject(Message))
}

pub fn middleware(
  req: wisp.Request,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  handle_request(req)
}
