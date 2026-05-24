# Example 12: Reactive Dashboard
#
# Demonstrates: reactive bindings, formula bindings, workers,
#               auto-updating UI, sparkline, multiple reactive targets.
#
# Run:
#   Rscript inst/examples/12-reactive-dashboard.R

library(rtui)

quick_app(
  title = "System Monitor",
  dark = TRUE,

  layout = vstack(
    header(),

    hstack(
      box(
        static("[bold]CPU Usage[/bold]", id = "cpu_label"),
        digits("0%", id = "cpu_display"),
        progress_bar(total = 100, progress = 0, id = "cpu_bar"),
        sparkline(rep(0, 20), id = "cpu_spark"),
        border = "round", id = "cpu_card"
      ),
      box(
        static("[bold]Memory[/bold]", id = "mem_label"),
        digits("0%", id = "mem_display"),
        progress_bar(total = 100, progress = 0, id = "mem_bar"),
        sparkline(rep(0, 20), id = "mem_spark"),
        border = "round", id = "mem_card"
      ),
      box(
        static("[bold]Disk I/O[/bold]", id = "disk_label"),
        digits("0", id = "disk_display"),
        progress_bar(total = 100, progress = 0, id = "disk_bar"),
        sparkline(rep(0, 20), id = "disk_spark"),
        border = "round", id = "disk_card"
      ),
      id = "cards_row"
    ),

    rule(label = "Event Log"),
    log_view(id = "event_log", max_lines = 200L),

    static("Monitoring... (updates every 2s)", id = "status"),
    footer(),
    id = "root"
  ),

  reactive = reactive(
    cpu = list(
      ~ update(.app, "cpu_display", value = paste0(.x, "%")),
      ~ update(.app, "cpu_bar", progress = .x)
    ),
    mem = list(
      ~ update(.app, "mem_display", value = paste0(.x, "%")),
      ~ update(.app, "mem_bar", progress = .x)
    ),
    disk = list(
      ~ update(.app, "disk_display", value = as.character(.x)),
      ~ update(.app, "disk_bar", progress = min(.x, 100L))
    )
  ),

  on_mount = function(event, state) {
    state$set("cpu", 0L)
    state$set("mem", 0L)
    state$set("disk", 0L)
    state$set("cpu_history", rep(0, 20))
    state$set("mem_history", rep(0, 20))
    state$set("disk_history", rep(0, 20))
    state$set("tick_count", 0L)

    # Start polling
    set_interval(state$app, 2, "monitor")
    log_write(state$app, "event_log", "Monitoring started.")
    state
  },

  on_timer = function(event, state) {
    if (event$timer_id == "monitor") {
      # Simulate readings
      cpu <- sample(15:85, 1)
      mem <- sample(40:90, 1)
      disk <- sample(5:60, 1)

      state$set("cpu", cpu)
      state$set("mem", mem)
      state$set("disk", disk)

      # Update history for sparklines
      cpu_hist <- c(state$get("cpu_history")[-1], cpu)
      mem_hist <- c(state$get("mem_history")[-1], mem)
      disk_hist <- c(state$get("disk_history")[-1], disk)
      state$set("cpu_history", cpu_hist)
      state$set("mem_history", mem_hist)
      state$set("disk_history", disk_hist)

      update(state$app, "cpu_spark", data = cpu_hist)
      update(state$app, "mem_spark", data = mem_hist)
      update(state$app, "disk_spark", data = disk_hist)

      n <- state$get("tick_count") + 1L
      state$set("tick_count", n)

      # Log warnings
      ts <- format(Sys.time(), "%H:%M:%S")
      if (cpu > 75) {
        log_write(state$app, "event_log",
                  sprintf("[%s] WARNING: CPU at %d%%", ts, cpu))
      }
      if (mem > 85) {
        log_write(state$app, "event_log",
                  sprintf("[%s] WARNING: Memory at %d%%", ts, mem))
        notify(state$app, sprintf("High memory: %d%%", mem),
               severity = "warning")
      }

      update(state$app, "status",
             content = sprintf("Tick %d | CPU: %d%% | Mem: %d%% | Disk: %d MB/s",
                               n, cpu, mem, disk))
    }
    state
  },

  bindings = list(
    binding("q", "quit_app", "Quit"),
    binding("d", "toggle_dark", "Dark mode")
  ),
  on_action = function(event, state) {
    if (event$value == "quit_app") return(quit(state))
    if (event$value == "toggle_dark") dark_toggle(state$app)
    state
  },

  css = paste0(
    tui_theme("nord"),
    "
    #cards_row { height: 14; padding: 0 1; }
    #cpu_card, #mem_card, #disk_card { width: 1fr; }
    Digits { text-align: center; height: 3; }
    ProgressBar { height: 1; margin: 0 1; }
    Sparkline { height: 3; margin: 0 1; }
    #event_log { height: 1fr; margin: 0 1; }
    #status { height: 1; dock: bottom; padding: 0 1; }
    Rule { margin: 0 1; }
    "
  )
)
