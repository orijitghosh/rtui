# Example 07: Stopwatch
#
# Demonstrates: timers (set_interval, clear_timer), state management,
#               progress bar, digits display, key bindings, dark toggle.
#
# Run:
#   Rscript inst/examples/07-timer.R

library(rtui)

format_time <- function(seconds) {
  mins <- seconds %/% 60
  secs <- seconds %% 60
  sprintf("%02d:%02d", mins, secs)
}

quick_app(
  title = "Stopwatch",
  dark = TRUE,

  layout = vstack(
    header(),
    center(
      vstack(
        digits("00:00", id = "display"),
        progress_bar(total = 600, progress = 0,
                     show_percentage = TRUE, id = "progress"),
        hstack(
          button("Start", id = "btn_start"),
          button("Lap", id = "btn_lap"),
          button("Reset", id = "btn_reset"),
          id = "controls"
        ),
        rule(label = "Laps"),
        log_view(id = "laps", max_lines = 50L),
        id = "panel"
      ),
      id = "main"
    ),
    footer(),
    id = "root"
  ),

  on_mount = function(event, state) {
    state$set("elapsed", 0L)
    state$set("running", FALSE)
    state$set("lap_count", 0L)
    state
  },

  on_timer = function(event, state) {
    if (event$timer_id == "tick" && isTRUE(state$get("running"))) {
      elapsed <- state$get("elapsed") + 1L
      state$set("elapsed", elapsed)
      update(state$app, "display", value = format_time(elapsed))
      update(state$app, "progress", progress = min(elapsed, 600L))
    }
    state
  },

  on_click = list(
    btn_start = function(event, state) {
      if (isTRUE(state$get("running"))) {
        # Pause
        state$set("running", FALSE)
        clear_timer(state$app, "tick")
        update(state$app, "btn_start", label = "Resume")
      } else {
        # Start / resume
        state$set("running", TRUE)
        set_interval(state$app, 1, "tick")
        update(state$app, "btn_start", label = "Pause")
      }
      state
    },

    btn_lap = function(event, state) {
      if (isTRUE(state$get("running"))) {
        n <- state$get("lap_count") + 1L
        state$set("lap_count", n)
        elapsed <- state$get("elapsed")
        log_write(state$app, "laps",
                  sprintf("Lap %d: %s", n, format_time(elapsed)))
      }
      state
    },

    btn_reset = function(event, state) {
      state$set("running", FALSE)
      state$set("elapsed", 0L)
      state$set("lap_count", 0L)
      clear_timer(state$app, "tick")
      update(state$app, "display", value = "00:00")
      update(state$app, "progress", progress = 0)
      update(state$app, "btn_start", label = "Start")
      state
    }
  ),

  bindings = list(
    binding("q", "quit_app", "Quit"),
    binding("space", "toggle_timer", "Start/Pause"),
    binding("d", "toggle_dark", "Dark mode")
  ),
  on_action = function(event, state) {
    if (event$value == "quit_app") return(quit(state))
    if (event$value == "toggle_dark") dark_toggle(state$app)
    if (event$value == "toggle_timer") {
      # Reuse the start/pause logic
      if (isTRUE(state$get("running"))) {
        state$set("running", FALSE)
        clear_timer(state$app, "tick")
        update(state$app, "btn_start", label = "Resume")
      } else {
        state$set("running", TRUE)
        set_interval(state$app, 1, "tick")
        update(state$app, "btn_start", label = "Pause")
      }
    }
    state
  },

  css = "
    #main { height: 1fr; }
    #panel { width: 50; height: 1fr; padding: 1; }
    #display { height: 5; }
    Digits { text-align: center; }
    #progress { height: 1; margin: 1 0; }
    #controls { height: 3; align: center middle; }
    Button { margin: 0 1; min-width: 10; }
    #laps { height: 1fr; margin: 1 0; }
    Rule { margin: 0; }
  "
)
