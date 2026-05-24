# Spike S2: Can a Python-side asyncio handler synchronously invoke an R
#           callback and receive a return value?
#
# Success: Round-trip an integer through a key event handler,
#          verified by R-side assertion.
#
# Run from a REAL TERMINAL (not RStudio):
#   Rscript spikes/S2_r_callback_roundtrip.R
#
# Expected: app launches, auto-sends a test, R callback fires,
#           return value reaches Python, app exits, R prints SUCCESS.

Sys.unsetenv("RETICULATE_PYTHON")
Sys.setenv(RETICULATE_PYTHON_ENV = "r-rtui")
library(reticulate)
use_virtualenv("r-rtui", required = TRUE)

# R callback that will be called from Python
callback_log <- list()

r_callback <- function(event_dict) {
  event_type <- event_dict[["type"]]
  message(sprintf("  R callback received event: type=%s", event_type))

  if (event_type == "test") {
    input_val <- event_dict[["value"]]
    result <- input_val + 100L
    callback_log[[length(callback_log) + 1L]] <<- list(
      input = input_val,
      output = result
    )
    message(sprintf("  R callback: %d + 100 = %d", input_val, result))
    return(result)
  }
  return(0L)
}

py_run_string("
from textual.app import App, ComposeResult
from textual.widgets import Static

class CallbackSpikeApp(App):
    def __init__(self, r_callback, **kwargs):
        super().__init__(**kwargs)
        self._r_callback = r_callback
        self._result = None

    def compose(self) -> ComposeResult:
        yield Static('S2 Spike: testing R callback round-trip...')

    def on_mount(self) -> None:
        self.set_timer(1, self._test_callback)

    def _test_callback(self) -> None:
        # Call R with a test event containing an integer
        result = self._r_callback({'type': 'test', 'value': 42})
        self._result = result
        self.set_timer(1, self._finish)

    def _finish(self) -> None:
        self.exit(self._result)
")

message("--- Launching callback spike app ---")

tryCatch(
  {
    py$app <- py_eval("CallbackSpikeApp(r.r_callback)")
    py_run_string("result = app.run()")
    py_result <- py$result

    message(sprintf("--- Python-side result: %s ---", as.character(py_result)))

    if (length(callback_log) > 0 && callback_log[[1]]$output == 142L) {
      message("S2 RESULT: SUCCESS")
      message("  - R callback was invoked from Python async handler")
      message("  - Input: 42, Output: 142 (verified on R side)")
      message(sprintf("  - Python received: %s", as.character(py_result)))
    } else {
      message("S2 RESULT: PARTIAL - callback fired but result mismatch")
    }
  },
  error = function(e) {
    message("S2 RESULT: FAILURE - ", conditionMessage(e))
    if (length(callback_log) > 0) {
      message("  (R callback DID fire, but app errored)")
    }
  }
)

message("--- R REPL is responsive ---")
