# Showcase: Pomodoro Timer
#
# A full-featured Pomodoro productivity timer with:
# - Big digit countdown, progress bar
# - Work/break cycle management
# - Session history log
# - Sound notification (system bell)
#
# Run from a REAL TERMINAL:
#   & "C:\Program Files\R\R-4.4.3\bin\Rscript.exe" spikes/showcase_pomodoro.R

Sys.unsetenv("RETICULATE_PYTHON")
Sys.setenv(RETICULATE_PYTHON_ENV = "r-rtui")

library(reticulate)
use_virtualenv("r-rtui", required = TRUE)

devtools::load_all(".")

message("--- Pomodoro Timer ---")
message("Press s to start, p to pause, r to reset.")
message("Press q to quit.")

# --- Config ---
WORK_MINUTES  <- 25L
BREAK_MINUTES <- 5L
LONG_BREAK    <- 15L
SESSIONS_BEFORE_LONG <- 4L

format_time <- function(seconds) {
  mins <- seconds %/% 60
  secs <- seconds %% 60
  sprintf("%02d:%02d", mins, secs)
}

# --- Build the app ---
quick_app(
  title = "Pomodoro Timer",
  dark = TRUE,

  layout = vstack(
    header(),

    # Main display
    center(
      vstack(
        # Mode indicator
        static("[bold]WORK[/bold]", id = "mode_label"),

        # Big timer display
        digits("25:00", id = "timer_display"),

        # Progress bar
        progress_bar(total = WORK_MINUTES * 60, progress = 0,
                     show_eta = FALSE, show_percentage = TRUE,
                     id = "timer_progress"),

        # Session counter
        static("Session 1 / 4", id = "session_label"),

        # Controls
        hstack(
          button("Start", id = "btn_start"),
          button("Pause", id = "btn_pause"),
          button("Reset", id = "btn_reset"),
          button("Skip", id = "btn_skip"),
          id = "controls"
        ),

        id = "timer_panel"
      ),
      id = "main_center"
    ),

    rule(label = "History"),

    # Session log
    log_view(id = "history_log", max_lines = 100L),

    # Status bar
    static("Press Start or 's' to begin a Pomodoro session.", id = "status_bar"),

    footer(),
    id = "root"
  ),

  on_mount = function(event, state) {
    state$set("running", FALSE)
    state$set("mode", "work")  # "work" or "break"
    state$set("remaining", WORK_MINUTES * 60L)
    state$set("total", WORK_MINUTES * 60L)
    state$set("session", 1L)
    state$set("completed", 0L)

    # Log start
    log_write(state$app, "history_log",
              sprintf("[dim]%s[/dim] Pomodoro Timer ready.",
                      format(Sys.time(), "%H:%M:%S")),
              markup = TRUE)
    state
  },

  on_timer = function(event, state) {
    if (event$timer_id == "tick" && isTRUE(state$get("running"))) {
      remaining <- state$get("remaining") - 1L
      state$set("remaining", remaining)

      total <- state$get("total")
      elapsed <- total - remaining

      # Update display
      update(state$app, "timer_display", value = format_time(remaining))
      update(state$app, "timer_progress", progress = elapsed)

      if (remaining <= 0L) {
        # Timer complete!
        clear_timer(state$app, "tick")
        state$set("running", FALSE)
        update(state$app, "btn_start", label = "Start")

        mode <- state$get("mode")
        session <- state$get("session")
        completed <- state$get("completed")
        ts <- format(Sys.time(), "%H:%M:%S")

        if (mode == "work") {
          # Work session complete
          completed <- completed + 1L
          state$set("completed", completed)
          notify(state$app, sprintf("Work session %d complete! Take a break.", completed),
                 severity = "info")
          log_write(state$app, "history_log",
                    sprintf("[green][%s] Session %d complete![/green]", ts, completed),
                    markup = TRUE)

          # System bell
          cat("\a")

          # Switch to break
          if (completed %% SESSIONS_BEFORE_LONG == 0L) {
            state$set("mode", "break")
            state$set("remaining", LONG_BREAK * 60L)
            state$set("total", LONG_BREAK * 60L)
            update(state$app, "mode_label",
                   content = sprintf("[bold green]LONG BREAK (%d min)[/bold green]", LONG_BREAK))
            update(state$app, "timer_display", value = format_time(LONG_BREAK * 60))
            update(state$app, "timer_progress", total = LONG_BREAK * 60)
            update(state$app, "timer_progress", progress = 0)
            update(state$app, "status_bar",
                   content = sprintf("Long break! %d sessions complete.", completed))
            log_write(state$app, "history_log",
                      sprintf("[cyan][%s] Long break (%d min)[/cyan]", ts, LONG_BREAK),
                      markup = TRUE)
          } else {
            state$set("mode", "break")
            state$set("remaining", BREAK_MINUTES * 60L)
            state$set("total", BREAK_MINUTES * 60L)
            update(state$app, "mode_label",
                   content = sprintf("[bold cyan]BREAK (%d min)[/bold cyan]", BREAK_MINUTES))
            update(state$app, "timer_display", value = format_time(BREAK_MINUTES * 60))
            update(state$app, "timer_progress", total = BREAK_MINUTES * 60)
            update(state$app, "timer_progress", progress = 0)
            update(state$app, "status_bar",
                   content = sprintf("Short break! %d/%d sessions.", completed, SESSIONS_BEFORE_LONG))
            log_write(state$app, "history_log",
                      sprintf("[cyan][%s] Short break (%d min)[/cyan]", ts, BREAK_MINUTES),
                      markup = TRUE)
          }

        } else {
          # Break complete — back to work
          session <- session + 1L
          state$set("session", session)
          state$set("mode", "work")
          state$set("remaining", WORK_MINUTES * 60L)
          state$set("total", WORK_MINUTES * 60L)
          update(state$app, "mode_label",
                 content = "[bold red]WORK[/bold red]")
          update(state$app, "timer_display", value = format_time(WORK_MINUTES * 60))
          update(state$app, "timer_progress", total = WORK_MINUTES * 60)
          update(state$app, "timer_progress", progress = 0)
          update(state$app, "session_label",
                 content = sprintf("Session %d / %d", session, SESSIONS_BEFORE_LONG))
          update(state$app, "status_bar", content = "Break over! Press Start to begin work.")
          notify(state$app, "Break over! Time to focus.", severity = "warning")
          cat("\a")
          log_write(state$app, "history_log",
                    sprintf("[yellow][%s] Break over. Session %d ready.[/yellow]",
                            format(Sys.time(), "%H:%M:%S"), session),
                    markup = TRUE)
        }

        update(state$app, "session_label",
               content = sprintf("Session %d / %d | Completed: %d",
                                 state$get("session"), SESSIONS_BEFORE_LONG, completed))
      }
    }
    state
  },

  on_click = list(
    btn_start = function(event, state) {
      if (!isTRUE(state$get("running"))) {
        state$set("running", TRUE)
        set_interval(state$app, 1, "tick")
        update(state$app, "btn_start", label = "Running...")
        mode <- state$get("mode")
        update(state$app, "mode_label",
               content = if (mode == "work") {
                 "[bold red]WORK[/bold red]"
               } else {
                 "[bold cyan]BREAK[/bold cyan]"
               })
        update(state$app, "status_bar",
               content = sprintf("%s timer running...",
                                 if (mode == "work") "Work" else "Break"))
        log_write(state$app, "history_log",
                  sprintf("[dim][%s] Timer started (%s)[/dim]",
                          format(Sys.time(), "%H:%M:%S"), mode),
                  markup = TRUE)
      }
      state
    },

    btn_pause = function(event, state) {
      if (isTRUE(state$get("running"))) {
        state$set("running", FALSE)
        clear_timer(state$app, "tick")
        update(state$app, "btn_start", label = "Resume")
        update(state$app, "status_bar",
               content = sprintf("Paused — %s remaining",
                                 format_time(state$get("remaining"))))
        log_write(state$app, "history_log",
                  sprintf("[dim][%s] Paused[/dim]", format(Sys.time(), "%H:%M:%S")),
                  markup = TRUE)
      }
      state
    },

    btn_reset = function(event, state) {
      state$set("running", FALSE)
      clear_timer(state$app, "tick")
      mode <- state$get("mode")
      if (mode == "work") {
        state$set("remaining", WORK_MINUTES * 60L)
        state$set("total", WORK_MINUTES * 60L)
        update(state$app, "timer_display", value = format_time(WORK_MINUTES * 60))
      } else {
        state$set("remaining", BREAK_MINUTES * 60L)
        state$set("total", BREAK_MINUTES * 60L)
        update(state$app, "timer_display", value = format_time(BREAK_MINUTES * 60))
      }
      update(state$app, "timer_progress", progress = 0)
      update(state$app, "btn_start", label = "Start")
      update(state$app, "status_bar", content = "Timer reset. Press Start.")
      state
    },

    btn_skip = function(event, state) {
      # Skip to next phase
      state$set("running", FALSE)
      clear_timer(state$app, "tick")
      state$set("remaining", 0L)

      mode <- state$get("mode")
      completed <- state$get("completed")
      session <- state$get("session")
      ts <- format(Sys.time(), "%H:%M:%S")

      if (mode == "work") {
        completed <- completed + 1L
        state$set("completed", completed)
        state$set("mode", "break")
        mins <- if (completed %% SESSIONS_BEFORE_LONG == 0) LONG_BREAK else BREAK_MINUTES
        state$set("remaining", mins * 60L)
        state$set("total", mins * 60L)
        update(state$app, "mode_label",
               content = sprintf("[bold cyan]BREAK (%d min)[/bold cyan]", mins))
        update(state$app, "timer_display", value = format_time(mins * 60))
        update(state$app, "timer_progress", total = mins * 60)
        update(state$app, "timer_progress", progress = 0)
        log_write(state$app, "history_log",
                  sprintf("[yellow][%s] Work skipped. Break time.[/yellow]", ts),
                  markup = TRUE)
      } else {
        session <- session + 1L
        state$set("session", session)
        state$set("mode", "work")
        state$set("remaining", WORK_MINUTES * 60L)
        state$set("total", WORK_MINUTES * 60L)
        update(state$app, "mode_label", content = "[bold red]WORK[/bold red]")
        update(state$app, "timer_display", value = format_time(WORK_MINUTES * 60))
        update(state$app, "timer_progress", total = WORK_MINUTES * 60)
        update(state$app, "timer_progress", progress = 0)
        log_write(state$app, "history_log",
                  sprintf("[yellow][%s] Break skipped. Session %d.[/yellow]", ts, session),
                  markup = TRUE)
      }
      update(state$app, "btn_start", label = "Start")
      update(state$app, "session_label",
             content = sprintf("Session %d / %d | Completed: %d",
                               state$get("session"), SESSIONS_BEFORE_LONG, completed))
      update(state$app, "status_bar", content = "Skipped. Press Start.")
      state
    }
  ),

  bindings = list(
    binding("q", "quit_app", "Quit", priority = TRUE),
    binding("escape", "quit_app", "Quit", priority = TRUE),
    binding("s", "start_timer", "Start", priority = TRUE),
    binding("p", "pause_timer", "Pause", priority = TRUE),
    binding("r", "reset_timer", "Reset", priority = TRUE),
    binding("d", "toggle_dark", "Dark mode", priority = TRUE)
  ),
  on_key = function(event, state) {
    if (event$key == "q" || event$key == "escape") return(quit(state))
    state
  },
  on_action = function(event, state) {
    if (event$value == "quit_app") return(quit(state))
    if (event$value == "toggle_dark") dark_toggle(state$app)
    # Delegate to click handlers
    if (event$value == "start_timer") {
      # Same as btn_start click
      if (!isTRUE(state$get("running"))) {
        state$set("running", TRUE)
        set_interval(state$app, 1, "tick")
        update(state$app, "btn_start", label = "Running...")
        update(state$app, "status_bar",
               content = sprintf("%s timer running...",
                                 if (state$get("mode") == "work") "Work" else "Break"))
      }
    }
    if (event$value == "pause_timer") {
      if (isTRUE(state$get("running"))) {
        state$set("running", FALSE)
        clear_timer(state$app, "tick")
        update(state$app, "btn_start", label = "Resume")
        update(state$app, "status_bar",
               content = sprintf("Paused — %s remaining",
                                 format_time(state$get("remaining"))))
      }
    }
    if (event$value == "reset_timer") {
      state$set("running", FALSE)
      clear_timer(state$app, "tick")
      mins <- if (state$get("mode") == "work") WORK_MINUTES else BREAK_MINUTES
      state$set("remaining", mins * 60L)
      update(state$app, "timer_display", value = format_time(mins * 60))
      update(state$app, "timer_progress", progress = 0)
      update(state$app, "btn_start", label = "Start")
      update(state$app, "status_bar", content = "Timer reset.")
    }
    state
  },

  css = paste0(
    tui_theme("sunset"),
    "
    #main_center { height: 1fr; }
    #timer_panel { height: auto; width: 50; padding: 1 2; }
    #mode_label { text-align: center; text-style: bold; height: 2; }
    #timer_display { height: 5; text-align: center; }
    Digits { text-align: center; }
    #timer_progress { height: 1; margin: 1 0; }
    #session_label { text-align: center; height: 1; }
    #controls { height: 3; align: center middle; }
    #history_log { height: 8; border: round #555; margin: 0 1; }
    #status_bar { height: 1; dock: bottom; padding: 0 1; }
    Button { margin: 0 1; min-width: 10; }
    Rule { margin: 0 1; }
    "
  )
)

message("--- Pomodoro Timer exited ---")
