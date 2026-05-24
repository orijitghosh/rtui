# End-to-end test: run the rtui hello example via the real package bridge.
#
# Run from a REAL TERMINAL:
#   & "C:\Program Files\R\R-4.4.3\bin\Rscript.exe" spikes/test_e2e_hello.R

Sys.unsetenv("RETICULATE_PYTHON")
Sys.setenv(RETICULATE_PYTHON_ENV = "r-rtui")

library(reticulate)
use_virtualenv("r-rtui", required = TRUE)

devtools::load_all(".")

app <- tui_app(
  layout = vstack(
    box(
      text("Hello from rtui!", id = "greeting"),
      border = "round",
      title = "Welcome"
    ),
    text("Press 'q' to quit.", id = "hint"),
    id = "root"
  ),
  on_key = function(event, state) {
    if (event$key == "q") return(quit(state))
    state
  },
  on_mount = function(event, state) {
    state$set("started", TRUE)
    state
  }
)

message("--- Launching rtui hello app (press 'q' to quit) ---")
result <- app$run()
message("--- App exited. State: ---")
print(result$as_list())
message("--- SUCCESS ---")
