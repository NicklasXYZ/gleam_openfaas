import gleam/http.{Request, Response}
import gleam/bit_builder.{BitBuilder}

// Required method: This is the entrypoint for all incoming requests
pub fn handler(req: Request(BitString)) -> Response(BitBuilder) {
  let body = bit_builder.from_string("Hello from OpenFaaS!")
  http.response(200)
  |> http.prepend_resp_header("made-with", "Gleam")
  |> http.set_resp_body(body)
}
