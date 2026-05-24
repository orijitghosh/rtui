library(rtui)

sections <- list(
  schema = "Columns: id (int), name (chr), value (dbl)",
  rows = "Total rows: 1,234 | Changed: 42 | Added: 5",
  meta = "Source: production_db | Snapshot: 2026-05-22"
)

app <- tui_app(
  layout = vstack(
    box(text("List-Detail Explorer", id = "title"), border = "round"),
    hstack(
      list_view(items = names(sections), id = "menu"),
      box(static("Use arrow keys to browse", id = "detail"),
          border = "round", id = "detail_box")
    ),
    id = "root"
  ),
  on_key = function(event, state) {
    if (event$key == "q") return(quit(state))
    state
  },
  on_mount = function(event, state) {
    state$set("started_at", Sys.time())
    state
  }
)

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

app$run()
