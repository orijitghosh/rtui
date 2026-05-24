# Showcase: Interactive Log Viewer
#
# Watches a log file (or generates sample logs), with severity filtering,
# search, auto-scroll, and clipboard copy.
#
# Run from a REAL TERMINAL:
#   & "C:\Program Files\R\R-4.4.3\bin\Rscript.exe" spikes/showcase_log_viewer.R

Sys.unsetenv("RETICULATE_PYTHON")
Sys.setenv(RETICULATE_PYTHON_ENV = "r-rtui")

library(reticulate)
use_virtualenv("r-rtui", required = TRUE)

devtools::load_all(".")

message("--- Log Viewer ---")
message("Generates simulated log entries. Use severity filter and search.")
message("Press q to quit.")

# --- Generate a random log entry ---
random_log_entry <- function() {
  severities <- c("INFO", "INFO", "INFO", "INFO", "WARN", "WARN", "ERROR", "DEBUG", "DEBUG")
  sources <- c("auth", "api", "db", "cache", "scheduler", "http", "worker", "queue")
  messages_info <- c(
    "Request processed successfully",
    "User session started",
    "Cache hit for key",
    "Database query completed in %dms",
    "Background job finished",
    "Health check passed",
    "Configuration reloaded"
  )
  messages_warn <- c(
    "Slow query detected (%dms)",
    "Rate limit approaching for client",
    "Memory usage above 80%%",
    "Retry attempt %d of 3",
    "Deprecated API endpoint called",
    "Connection pool running low"
  )
  messages_error <- c(
    "Failed to connect to database",
    "Timeout after %d seconds",
    "Authentication failed for user",
    "Disk space critically low",
    "Unhandled exception in worker",
    "Service unavailable: upstream timeout"
  )
  messages_debug <- c(
    "Entering function process_request()",
    "Cache key generated: %s",
    "SQL: SELECT * FROM users WHERE id = %d",
    "Response payload: %d bytes",
    "Thread pool size: %d"
  )

  sev <- sample(severities, 1)
  src <- sample(sources, 1)
  ts <- format(Sys.time(), "%H:%M:%S")

  msg <- switch(sev,
    INFO  = sprintf(sample(messages_info, 1), sample(10:500, 1)),
    WARN  = sprintf(sample(messages_warn, 1), sample(10:500, 1)),
    ERROR = sprintf(sample(messages_error, 1), sample(10:60, 1)),
    DEBUG = sprintf(sample(messages_debug, 1), sample(10:9999, 1))
  )

  list(
    severity = sev,
    source = src,
    timestamp = ts,
    message = msg,
    formatted = sprintf("[%s] [%-5s] [%s] %s", ts, sev, src, msg)
  )
}

# --- Colorize a log line based on severity ---
colorize_log <- function(entry) {
  sev <- entry$severity
  color <- switch(sev,
    ERROR = "red",
    WARN  = "yellow",
    INFO  = "green",
    DEBUG = "dim white",
    "white"
  )
  sprintf("[%s]%s[/%s]", color, entry$formatted, color)
}

# --- Build the app ---
quick_app(
  title = "Log Viewer",
  dark = TRUE,

  layout = vstack(
    header(),

    # Controls
    hstack(
      static("Filter:", id = "lbl_filter"),
      select(c("ALL", "ERROR", "WARN", "INFO", "DEBUG"),
             value = "ALL", prompt = "Severity", id = "sev_filter"),
      static("Search:", id = "lbl_search"),
      input(placeholder = "text to find...", id = "search_input"),
      button("Clear", id = "btn_clear"),
      button("Pause", id = "btn_pause"),
      id = "controls"
    ),

    # Counters
    hstack(
      static("[green]INFO: 0[/green]", id = "cnt_info"),
      static("[yellow]WARN: 0[/yellow]", id = "cnt_warn"),
      static("[red]ERROR: 0[/red]", id = "cnt_error"),
      static("[dim]DEBUG: 0[/dim]", id = "cnt_debug"),
      static("Total: 0", id = "cnt_total"),
      id = "counters"
    ),

    # Log output
    log_view(id = "log_output", max_lines = 500L),

    # Status
    static("Generating logs...", id = "status_bar"),

    footer(),
    id = "root"
  ),

  on_mount = function(event, state) {
    state$set("paused", FALSE)
    state$set(".filter", "ALL")
    state$set(".search", "")
    state$set(".counts", list(INFO = 0L, WARN = 0L, ERROR = 0L, DEBUG = 0L))
    # Generate logs every 0.5 seconds
    set_interval(state$app, 0.5, "gen_log")
    state
  },

  on_timer = function(event, state) {
    if (event$timer_id == "gen_log" && !isTRUE(state$get("paused"))) {
      tryCatch({
        # Generate 1-3 log entries per tick
        n <- sample(1:3, 1)
        filter_sev <- state$get(".filter", "ALL")
        search_term <- state$get(".search", "")
        counts <- state$get(".counts")

        for (i in seq_len(n)) {
          entry <- random_log_entry()
          sev <- entry$severity

          # Update counts
          counts[[sev]] <- counts[[sev]] + 1L

          # Check filter
          if (filter_sev != "ALL" && sev != filter_sev) next

          # Check search
          if (nzchar(search_term)) {
            if (!grepl(search_term, entry$formatted, ignore.case = TRUE)) next
          }

          # Write colorized log line
          log_write(state$app, "log_output", colorize_log(entry), markup = TRUE)
        }

        state$set(".counts", counts)
        total <- counts$INFO + counts$WARN + counts$ERROR + counts$DEBUG

        # Update counters
        update(state$app, "cnt_info",
               content = sprintf("[green]INFO: %d[/green]", counts$INFO))
        update(state$app, "cnt_warn",
               content = sprintf("[yellow]WARN: %d[/yellow]", counts$WARN))
        update(state$app, "cnt_error",
               content = sprintf("[red]ERROR: %d[/red]", counts$ERROR))
        update(state$app, "cnt_debug",
               content = sprintf("[dim]DEBUG: %d[/dim]", counts$DEBUG))
        update(state$app, "cnt_total",
               content = sprintf("Total: %d", total))
        update(state$app, "status_bar",
               content = sprintf("Generating | Filter: %s | Total: %d",
                                 filter_sev, total))
      }, error = function(e) {
        notify(state$app, paste("Error:", conditionMessage(e)), severity = "error")
      })
    }
    state
  },

  on_change = list(
    sev_filter = function(event, state) {
      val <- event$value
      if (!is.null(val)) {
        state$set(".filter", val)
        update(state$app, "log_output", clear = TRUE)
        notify(state$app, paste("Filter:", val), severity = "info")
      }
      state
    },
    search_input = function(event, state) {
      val <- if (is.list(event$value)) event$value$text else event$value
      if (is.null(val)) val <- ""
      state$set(".search", val)
      state
    }
  ),

  on_click = list(
    btn_clear = function(event, state) {
      update(state$app, "log_output", clear = TRUE)
      state$set(".counts", list(INFO = 0L, WARN = 0L, ERROR = 0L, DEBUG = 0L))
      update(state$app, "cnt_info", content = "[green]INFO: 0[/green]")
      update(state$app, "cnt_warn", content = "[yellow]WARN: 0[/yellow]")
      update(state$app, "cnt_error", content = "[red]ERROR: 0[/red]")
      update(state$app, "cnt_debug", content = "[dim]DEBUG: 0[/dim]")
      update(state$app, "cnt_total", content = "Total: 0")
      notify(state$app, "Log cleared", severity = "info")
      state
    },
    btn_pause = function(event, state) {
      paused <- !isTRUE(state$get("paused"))
      state$set("paused", paused)
      update(state$app, "btn_pause", label = if (paused) "Resume" else "Pause")
      update(state$app, "status_bar",
             content = if (paused) "PAUSED" else "Generating...")
      state
    }
  ),

  bindings = list(
    binding("q", "quit_app", "Quit", priority = TRUE),
    binding("escape", "quit_app", "Quit", priority = TRUE),
    binding("p", "toggle_pause", "Pause", priority = TRUE),
    binding("c", "clear_log", "Clear", priority = TRUE),
    binding("d", "toggle_dark", "Dark mode", priority = TRUE)
  ),
  on_key = function(event, state) {
    if (event$key == "q" || event$key == "escape") return(quit(state))
    state
  },
  on_action = function(event, state) {
    if (event$value == "quit_app") return(quit(state))
    if (event$value == "toggle_pause") {
      paused <- !isTRUE(state$get("paused"))
      state$set("paused", paused)
      update(state$app, "btn_pause", label = if (paused) "Resume" else "Pause")
      update(state$app, "status_bar",
             content = if (paused) "PAUSED" else "Generating...")
    }
    if (event$value == "clear_log") {
      update(state$app, "log_output", clear = TRUE)
      notify(state$app, "Log cleared", severity = "info")
    }
    if (event$value == "toggle_dark") dark_toggle(state$app)
    state
  },

  css = paste0(
    tui_theme("monokai"),
    "
    #controls { height: 3; align: left middle; padding: 0 1; }
    #lbl_filter, #lbl_search { width: auto; padding: 0 1; }
    #sev_filter { width: 15; }
    #search_input { width: 25; }
    #counters { height: 1; align: center middle; padding: 0 1; }
    #cnt_info, #cnt_warn, #cnt_error, #cnt_debug, #cnt_total {
      width: auto; padding: 0 2;
    }
    #log_output { height: 1fr; border: round #3e3d32; }
    #status_bar { height: 1; dock: bottom; background: #3e3d32;
                  color: #a6e22e; padding: 0 1; }
    Button { margin: 0 1; }
    "
  )
)

message("--- Log Viewer exited ---")
