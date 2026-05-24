# Showcase: simplified API with per-widget-id routing + quick_app()
#
# Run from a REAL TERMINAL:
#   & "C:\Program Files\R\R-4.4.3\bin\Rscript.exe" spikes/test_simplified_api.R

Sys.unsetenv("RETICULATE_PYTHON")
Sys.setenv(RETICULATE_PYTHON_ENV = "r-rtui")

library(reticulate)
use_virtualenv("r-rtui", required = TRUE)

devtools::load_all(".")

# --- Example 1: Counter app in ~30 lines with per-widget-id routing ---
message("--- Launching counter app (press +/- or click buttons, escape to quit) ---")

quick_app(
  title = "Counter",
  dark = TRUE,
  layout = vstack(
    header(),
    center(
      middle(
        vstack(
          digits("0", id = "display"),
          hstack(
            button("-1", id = "dec"),
            button("+1", id = "inc"),
            button("Reset", id = "reset"),
            id = "buttons"
          ),
          id = "counter_panel"
        ),
        id = "mid"
      ),
      id = "ctr"
    ),
    footer(),
    id = "root"
  ),

  # Per-widget-id routing — no more switch/if-else chains!
  on_click = list(
    inc = function(event, state) {
      n <- state$get("count", 0L) + 1L
      state$set("count", n)
      update(state$app, "display", value = as.character(n))
      state
    },
    dec = function(event, state) {
      n <- state$get("count", 0L) - 1L
      state$set("count", n)
      update(state$app, "display", value = as.character(n))
      state
    },
    reset = function(event, state) {
      state$set("count", 0L)
      update(state$app, "display", value = "0")
      notify(state$app, "Counter reset!", severity = "info")
      state
    }
  ),

  on_key = function(event, state) {
    if (event$key == "q" || event$key == "escape") return(quit(state))
    state
  },

  bindings = list(
    binding("q", "quit_app", "Quit", priority = TRUE),
    binding("escape", "quit_app", "Quit", priority = TRUE)
  ),
  on_action = function(event, state) {
    if (event$value == "quit_app") return(quit(state))
    state
  },

  css = "
    #counter_panel { align: center middle; width: auto; }
    #display { text-align: center; }
    #buttons { align: center middle; }
    Button { margin: 0 1; }
  "
)

message("--- Counter app exited ---")
