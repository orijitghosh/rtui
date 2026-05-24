library(rtui)

app <- tui_app(
  layout = vstack(
    box(text("Data Table Viewer", id = "title"), border = "round"),
    data_table(head(mtcars, 20), id = "table"),
    text("Press 'q' to quit.", id = "hint"),
    id = "root"
  ),
  on_key = function(event, state) {
    if (event$key == "q") return(quit(state))
    state
  }
)

app$run()
