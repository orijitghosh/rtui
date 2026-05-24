# End-to-end test: list-detail layout with ListView selection updating detail.
#
# Run from a REAL TERMINAL:
#   & "C:\Program Files\R\R-4.4.3\bin\Rscript.exe" spikes/test_e2e_list_detail.R

Sys.unsetenv("RETICULATE_PYTHON")
Sys.setenv(RETICULATE_PYTHON_ENV = "r-rtui")

library(reticulate)
use_virtualenv("r-rtui", required = TRUE)

devtools::load_all(".")

sections <- list(
  schema = "Columns: id (int), name (chr), value (dbl)",
  rows = "Total rows: 1,234 | Changed: 42 | Added: 5 | Removed: 2",
  meta = "Source: production_db | Snapshot: 2026-05-22T10:30:00Z"
)

app <- tui_app(
  layout = vstack(
    box(text("List-Detail Explorer", id = "title"), border = "round"),
    hstack(
      list_view(items = names(sections), id = "menu"),
      box(static("Use arrow keys to browse, q to quit", id = "detail"),
          border = "round", id = "detail_box")
    ),
    id = "root"
  ),
  on_key = function(event, state) {
    if (event$key == "q") return(quit(state))
    state
  },
  on_mount = function(event, state) {
    state$set("started_at", as.character(Sys.time()))
    state
  }
)

# Use closure to capture app for update() calls in the change handler
original_handlers <- app$handlers
app$handlers$change <- function(event, state) {
  if (!is.null(event$widget_id) && event$widget_id == "menu") {
    label <- event$value$label
    if (!is.null(label) && label %in% names(sections)) {
      update(app, "detail", content = sections[[label]])
      state$set("selected", label)
    }
  }
  state
}

message("--- Launching list-detail app (arrows to navigate, q to quit) ---")
result <- app$run()
message("--- App exited. State: ---")
print(result$as_list())
message("--- SUCCESS ---")
