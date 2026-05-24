# End-to-end test: data table widget with mtcars.
#
# Run from a REAL TERMINAL:
#   & "C:\Program Files\R\R-4.4.3\bin\Rscript.exe" spikes/test_e2e_data_table.R

Sys.unsetenv("RETICULATE_PYTHON")
Sys.setenv(RETICULATE_PYTHON_ENV = "r-rtui")

library(reticulate)
use_virtualenv("r-rtui", required = TRUE)

devtools::load_all(".")

app <- tui_app(
  layout = vstack(
    box(text("Data Table Viewer", id = "title"), border = "round"),
    data_table(head(mtcars, 10), id = "table"),
    text("Press 'q' to quit.", id = "hint"),
    id = "root"
  ),
  on_key = function(event, state) {
    if (event$key == "q") return(quit(state))
    state
  }
)

message("--- Launching data table app (q to quit) ---")
result <- app$run()
message("--- App exited ---")
message("--- SUCCESS ---")
