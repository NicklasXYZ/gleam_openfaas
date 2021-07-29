import gleam/bit_builder
import gleam/http.{Post}
import gleam/http/elli
import gleam/http/middleware
import gleam_openfaas/web/logger
import function

// Start the Elli webserver and handle incoming requests by passing them 
// through the 'function.service' function.
pub fn start() {
  let service =
    function.service
    |> middleware.prepend_resp_header("made-with", "Gleam")
    |> middleware.map_resp_body(bit_builder.from_bit_string)
    |> logger.middleware

  elli.start(service, on_port: 8000)
}
