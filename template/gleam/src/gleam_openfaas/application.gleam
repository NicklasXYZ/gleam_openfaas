import gleam/otp/supervisor.{
  ApplicationStartMode, ErlangStartResult, add, worker,
}
import gleam/dynamic.{Dynamic}
import gleam_openfaas/gleam_openfaas

fn init(children) {
  children
  |> add(worker(fn(_) { gleam_openfaas.start() }))
}

pub fn start(
  _mode: ApplicationStartMode,
  _args: List(Dynamic),
) -> ErlangStartResult {
  init
  |> supervisor.start
  |> supervisor.to_erlang_start_result
}

pub fn stop(_state: Dynamic) {
  supervisor.application_stopped()
}
