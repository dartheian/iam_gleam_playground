import gleam/erlang/process
import iam_gleam_playground/router
import iam_gleam_playground/web
import mist
import radish
import wisp
import wisp/wisp_mist

pub fn main() {
  let assert Ok(redis_client) = radish.start("redis", 6379, [])
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)
  let context = web.Context(redis_client: redis_client)
  let handler = router.handle_request(_, context)
  let assert Ok(_) =
    handler
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http
  process.sleep_forever()
}
