import gleam/http/elli
import function

// Elli webserver entrypoint. The function 'function.handler' handles
// all incoming requests to http://localhost:3000/
pub fn start() {
  elli.start(function.handler, on_port: 3000)
}
