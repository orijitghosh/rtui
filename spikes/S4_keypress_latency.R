# Spike S4: What is observed keypress-to-callback latency?
#
# Success: Measured median latency reported.
#
# Run from a REAL TERMINAL (not RStudio):
#   Rscript spikes/S4_keypress_latency.R
#
# This app sends simulated key events via timer and measures
# the round-trip time from Python event to R callback return.
# Auto-exits after 20 measurements.

Sys.unsetenv("RETICULATE_PYTHON")
Sys.setenv(RETICULATE_PYTHON_ENV = "r-rtui")
library(reticulate)
use_virtualenv("r-rtui", required = TRUE)

latencies_ms <- numeric(0)

r_latency_callback <- function(event_dict) {
  if (event_dict[["type"]] == "key") {
    py_send_time <- event_dict[["_send_time"]]
    if (!is.null(py_send_time)) {
      now <- as.numeric(Sys.time())
      latency_ms <- (now - py_send_time) * 1000
      latencies_ms <<- c(latencies_ms, latency_ms)
    }
  }
  return(length(latencies_ms))
}

py_run_string("
import time
from textual.app import App, ComposeResult
from textual.widgets import Static

class LatencySpikeApp(App):
    def __init__(self, r_callback, **kwargs):
        super().__init__(**kwargs)
        self._r_callback = r_callback
        self._count = 0
        self._max = 20

    def compose(self) -> ComposeResult:
        yield Static('S4 Spike: measuring keypress latency (20 events)...')

    def on_mount(self) -> None:
        self.set_timer(0.5, self._send_event)

    def _send_event(self) -> None:
        event = {
            'type': 'key',
            'key': 'a',
            '_send_time': time.time(),
        }
        count = self._r_callback(event)
        self._count += 1
        if self._count < self._max:
            self.set_timer(0.1, self._send_event)
        else:
            self.set_timer(0.5, lambda: self.exit('done'))
")

message("--- Launching latency measurement app (20 events) ---")

tryCatch(
  {
    py$app <- py_eval("LatencySpikeApp(r.r_latency_callback)")
    py_run_string("app.run()")

    if (length(latencies_ms) > 0) {
      message(sprintf("\nS4 RESULTS: %d measurements", length(latencies_ms)))
      message(sprintf("  Median:  %.2f ms", median(latencies_ms)))
      message(sprintf("  Mean:    %.2f ms", mean(latencies_ms)))
      message(sprintf("  P95:     %.2f ms", quantile(latencies_ms, 0.95)))
      message(sprintf("  Min:     %.2f ms", min(latencies_ms)))
      message(sprintf("  Max:     %.2f ms", max(latencies_ms)))

      if (quantile(latencies_ms, 0.95) <= 50) {
        message("S4 RESULT: SUCCESS - p95 latency within 50ms ceiling")
      } else {
        message("S4 RESULT: WARNING - p95 latency exceeds 50ms ceiling")
      }
    } else {
      message("S4 RESULT: FAILURE - no latency measurements collected")
    }
  },
  error = function(e) {
    message("S4 RESULT: FAILURE - ", conditionMessage(e))
  }
)

message("--- R REPL is responsive ---")
