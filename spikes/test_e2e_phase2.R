# End-to-end test: Phase 2 features — timers, screens, bindings, tooltips,
# DirectoryTree, app title/dark mode, input validation.
#
# Run from a REAL TERMINAL:
#   & "C:\Program Files\R\R-4.4.3\bin\Rscript.exe" spikes/test_e2e_phase2.R

Sys.unsetenv("RETICULATE_PYTHON")
Sys.setenv(RETICULATE_PYTHON_ENV = "r-rtui")

library(reticulate)
use_virtualenv("r-rtui", required = TRUE)

devtools::load_all(".")

# --- Modal screen layout ---
modal_screen <- tui_screen(

  layout = vstack(
    text("Are you sure?", id = "modal_title"),
    hstack(
      button("Yes", id = "yes_btn", tooltip = "Confirm action"),
      button("No", id = "no_btn", tooltip = "Cancel action"),
      id = "modal_buttons"
    ),
    id = "modal_root"
  ),
  css = "
    #modal_root { align: center middle; }
    #modal_title { text-align: center; }
  "
)

# --- Main app ---
app <- tui_app(
  title = "rtui Phase 2 Test",
  sub_title = "Timers + Screens + Bindings",
  dark = TRUE,
  layout = vstack(
    header(show_clock = TRUE),
    hstack(
      vstack(
        text("Timer count: 0", id = "timer_display"),
        static("Press 'm' to open modal", id = "hint"),
        input(
          placeholder = "Type a number...",
          id = "num_input",
          validators = c("number"),
          tooltip = "Only numeric values accepted"
        ),
        button("Open Modal", id = "open_modal", tooltip = "Opens a confirmation dialog"),
        rule(),
        text("Validation: n/a", id = "valid_display"),
        id = "left_col"
      ),
      vstack(
        directory_tree(path = ".", id = "files"),
        id = "right_col"
      ),
      id = "main_row"
    ),
    footer(),
    id = "root"
  ),
  bindings = list(
    binding("m", "open_modal", "Open modal"),
    binding("d", "toggle_dark", "Toggle dark"),
    binding("q", "quit_app", "Quit", priority = TRUE),
    binding("escape", "quit_app", "Quit", priority = TRUE)
  ),
  on_action = function(event, state) {
    if (event$value == "quit_app") return(quit(state))
    if (event$value == "open_modal") {
      push_screen(app, modal_screen)
    }
    state
  },
  on_mount = function(event, state) {
    state$set("tick", 0L)
    # Start a 1-second interval timer
    set_interval(app, 1, "clock_tick")
    # Auto-quit after 8 seconds (gives time to see timer ticking)
    set_timer(app, 8, "auto_quit")
    state
  },
  on_key = function(event, state) {
    # NOTE: 'q' won't fire here when an Input widget has focus —
    # Textual routes keystrokes to the focused widget first.
    # Use 'escape' or click outside the input first.
    if (event$key == "q" || event$key == "escape") return(quit(state))
    state
  },
  css = "
    #left_col { width: 1fr; }
    #right_col { width: 1fr; }
  "
)

# Timer handler
app$handlers$timer <- function(event, state) {
  if (event$timer_id == "clock_tick") {
    n <- state$get("tick", 0L) + 1L
    state$set("tick", n)
    update(app, "timer_display", content = paste("Timer count:", n))
  }
  if (event$timer_id == "auto_quit") {
    return(quit(state))
  }
  state
}

# Modal screen result handler
app$handlers$screen_result <- function(event, state) {
  msg <- if (!is.null(event$value)) "Modal result received" else "Modal dismissed"
  update(app, "hint", content = msg)
  state
}

# Change handler (for input validation and directory tree)
app$handlers$change <- function(event, state) {
  if (!is.null(event$widget_id) && event$widget_id == "num_input") {
    if (is.list(event$value)) {
      valid <- if (event$value$valid) "VALID" else "INVALID"
      txt <- event$value$text
      update(app, "valid_display",
             content = sprintf("Validation: %s (value: %s)", valid, txt))
    }
  }
  state
}

# Click handler (for modal buttons and file selection)
app$handlers$click <- function(event, state) {
  if (!is.null(event$widget_id)) {
    if (event$widget_id == "open_modal") {
      push_screen(app, modal_screen)
    } else if (event$widget_id == "yes_btn") {
      pop_screen(app, result = "confirmed")
    } else if (event$widget_id == "no_btn") {
      pop_screen(app, result = "cancelled")
    } else if (event$widget_id == "files") {
      if (is.list(event$value) && !is.null(event$value$path)) {
        update(app, "hint", content = paste("Selected:", event$value$path))
      }
    }
  }
  state
}

message("--- Launching Phase 2 test (auto-quits after 8s, or press q/escape) ---")
result <- app$run()
ticks <- result$get("tick", 0L)
message(sprintf("--- App exited. Timer ticks: %d ---", ticks))
if (ticks >= 3) {
  message("--- SUCCESS: Timer fired at least 3 times ---")
} else {
  message(sprintf("--- WARNING: Only %d ticks (expected >= 3) ---", ticks))
}
