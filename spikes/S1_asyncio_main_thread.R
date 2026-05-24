# Spike S1: Can Textual's asyncio loop run on the main thread
#            without freezing R's REPL on exit?
#
# Success: Launch a 5-second auto-exit Textual app from R via reticulate;
#          R returns control cleanly.
#
# Run from a REAL TERMINAL (not RStudio):
#   Rscript spikes/S1_asyncio_main_thread.R
#
# Expected: app appears, auto-exits after ~3 seconds, R prints "SUCCESS" and exits.

Sys.unsetenv("RETICULATE_PYTHON")
Sys.setenv(RETICULATE_PYTHON_ENV = "r-rtui")
library(reticulate)
use_virtualenv("r-rtui", required = TRUE)

py_run_string("
import asyncio
from textual.app import App, ComposeResult
from textual.widgets import Static

class SpikeApp(App):
    def compose(self) -> ComposeResult:
        yield Static('S1 Spike: auto-exit in 3 seconds...')

    def on_mount(self) -> None:
        self.set_timer(3, self._auto_exit)

    def _auto_exit(self) -> None:
        self.exit('done')

app = SpikeApp()
")

message("--- Launching Textual app (should auto-exit in ~3s) ---")

start_time <- proc.time()

tryCatch(
  {
    py_run_string("app.run()")
    elapsed <- (proc.time() - start_time)["elapsed"]
    message(sprintf("--- App exited cleanly after %.1f seconds ---", elapsed))
    message("S1 RESULT: SUCCESS - R regained control after Textual exit.")
  },
  error = function(e) {
    message("S1 RESULT: FAILURE - ", conditionMessage(e))
  }
)

message("--- R REPL is responsive (this line proves it) ---")
