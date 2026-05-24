# Showcase: Reactive state — no manual update() calls needed
#
# Compare with spikes/test_simplified_api.R: same counter app, but
# every state$set() auto-updates bound widgets. Cleaner handlers.
#
# Run from a REAL TERMINAL:
#   & "C:\Program Files\R\R-4.4.3\bin\Rscript.exe" spikes/test_reactive.R

Sys.unsetenv("RETICULATE_PYTHON")
Sys.setenv(RETICULATE_PYTHON_ENV = "r-rtui")

library(reticulate)
use_virtualenv("r-rtui", required = TRUE)

devtools::load_all(".")

message("--- Reactive Counter Demo ---")
message("Click +/-/Reset. Widgets auto-update from state.")
message("Press q or Escape to quit.")

quick_app(
  title = "Reactive Counter",
  dark = TRUE,

  layout = vstack(
    header(),
    center(
      middle(
        vstack(
          digits("0", id = "display"),
          static("Count: 0", id = "label"),
          static("", id = "status"),
          hstack(
            button("-1", id = "dec"),
            button("+1", id = "inc"),
            button("Reset", id = "reset"),
            id = "buttons"
          ),
          id = "panel"
        ),
        id = "mid"
      ),
      id = "ctr"
    ),
    footer(),
    id = "root"
  ),

  # --- Reactive bindings: declare once, no manual update() needed! ---
  reactive = reactive(
    # 1. Simple string form: state$count auto-updates "display" widget's value
    count = list(
      "display",
      # 2. Formula form: transform value, then update another widget
      ~ update(.app, "label", content = paste("Count:", .x)),
      # 3. Function form: full control (e.g. notify on milestones)
      function(value, state, app) {
        if (value == 10L) {
          notify(app, "Reached 10!", severity = "info")
          update(app, "status", content = "[b green]Milestone: 10![/]")
        } else if (value == 0L) {
          update(app, "status", content = "")
        } else if (value < 0L) {
          update(app, "status", content = "[b red]Negative![/]")
        } else {
          update(app, "status", content = "")
        }
      }
    )
  ),

  # --- Click handlers: just update state, widgets follow automatically ---
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
      state
    }
  ),

  bindings = list(
    binding("q", "quit_app", "Quit", priority = TRUE),
    binding("escape", "quit_app", "Quit", priority = TRUE)
  ),
  on_key = function(event, state) {
    if (event$key == "q" || event$key == "escape") return(quit(state))
    state
  },
  on_action = function(event, state) {
    if (event$value == "quit_app") return(quit(state))
    state
  },

  css = "
    #panel { align: center middle; width: auto; }
    #display { text-align: center; color: $accent; }
    #label, #status { text-align: center; }
    #status { color: $warning; }
    #buttons { align: center middle; }
    Button { margin: 0 1; }
  "
)

message("--- Reactive Counter exited ---")
