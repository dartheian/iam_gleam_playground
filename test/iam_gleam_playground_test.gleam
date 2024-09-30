import gleam/json
import gleeunit
import gleeunit/should
import iam_gleam_playground/router
import iam_gleam_playground/web.{type Context, Context}
import radish
import wisp/testing

pub fn main() {
  gleeunit.main()
}

fn with_context(testcase: fn(Context) -> t) -> t {
  let assert Ok(redis_client) = radish.start("redis", 6379, [])
  testcase(Context(redis_client))
}

pub fn health_check_test() {
  use context <- with_context
  let response =
    router.handle_request(testing.get("/health-check", []), context)
  response.status
  |> should.equal(200)
}

pub fn happy_path_test() {
  use context <- with_context
  let response = router.handle_request(testing.get("/key", []), context)
  response.status
  |> should.equal(404)
  let json = json.object([#("content", json.string("123"))])
  let response =
    router.handle_request(testing.put_json("/key", [], json), context)
  response.status
  |> should.equal(200)
  let response = router.handle_request(testing.get("/key", []), context)
  response.status
  |> should.equal(200)
  response
  |> testing.string_body
  |> should.equal("123")
}
