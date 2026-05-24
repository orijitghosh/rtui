# Example 05: Reactive Counter
#
# Demonstrates: buttons, click handlers, state management,
#               reactive bindings, digits widget, notifications.
#
# Run:
#   Rscript inst/examples/05-counter.R

library(rtui)

quick_app(
  title = "Counter",
  dark = TRUE,

  layout = vstack(
    header(),
    center(
      vstack(
        digits("0", id = "display"),
        hstack(
          button("-1", id = "dec"),
          button("Reset", id = "reset"),
          button("+1", id = "inc"),
          id = "buttons"
        ),
        id = "panel"
      ),
      id = "main"
    ),
    footer(),
    id = "root"
  ),

  reactive = reactive(
    count = "display"
  ),

  on_mount = function(event, state) {
    state$set("count", 0L)
    state
  },

  on_click = list(
    inc = function(event, state) {
      state$set("count", state$get("count", 0L) + 1L)
      state
    },
    dec = function(event, state) {
      state$set("count", state$get("count", 0L) - 1L)
      state
    },
    reset = function(event, state) {
      state$set("count", 0L)
      notify(state$app, "Counter reset.", severity = "info")
      state
    }
  ),

  bindings = list(
    binding("q", "quit_app", "Quit"),
    binding("escape", "quit_app", "Quit")
  ),
  on_action = function(event, state) {
    if (event$value == "quit_app") return(quit(state))
    state
  },

  css = "
    #main { height: 1fr; }
    #panel { height: auto; width: 40; }
    #display { height: 5; }
    Digits { text-align: center; }
    #buttons { height: 3; align: center middle; }
    Button { margin: 0 1; min-width: 8; }
  "
)
