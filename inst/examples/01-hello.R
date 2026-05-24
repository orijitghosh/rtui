library(rtui)

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
  }
)

app$run()
