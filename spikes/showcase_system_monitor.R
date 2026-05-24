# Showcase: Live System Monitor
#
# Displays real-time CPU, memory, disk, and process info using
# sparklines, progress bars, and a sortable data table.
#
# Run from a REAL TERMINAL:
#   & "C:\Program Files\R\R-4.4.3\bin\Rscript.exe" spikes/showcase_system_monitor.R

Sys.unsetenv("RETICULATE_PYTHON")
Sys.setenv(RETICULATE_PYTHON_ENV = "r-rtui")

library(reticulate)
use_virtualenv("r-rtui", required = TRUE)

devtools::load_all(".")

message("--- System Monitor ---")
message("Live CPU/memory/disk stats. Press q to quit.")

# --- Helpers: fetch system stats via Python's psutil ---
ensure_psutil <- function() {
  tryCatch(
    py_run_string("import psutil"),
    error = function(e) {
      message("Installing psutil...")
      py_run_string("import subprocess, sys; subprocess.check_call([sys.executable, '-m', 'pip', 'install', 'psutil'])")
      py_run_string("import psutil")
    }
  )
}

get_cpu_percent <- function() {
  py_run_string("import psutil; _cpu = psutil.cpu_percent(interval=0.1)")
  py$`_cpu`
}

get_memory <- function() {
  py_run_string("
import psutil
_mem = psutil.virtual_memory()
_mem_info = {'total': _mem.total / (1024**3), 'used': _mem.used / (1024**3),
             'percent': _mem.percent}
")
  py$`_mem_info`
}

get_disk <- function() {
  py_run_string("
import psutil
_disk = psutil.disk_usage('/')
_disk_info = {'total': _disk.total / (1024**3), 'used': _disk.used / (1024**3),
              'percent': _disk.percent}
")
  py$`_disk_info`
}

get_top_processes <- function(n = 10L) {
  py_run_string(sprintf("
import psutil
_procs = []
for p in psutil.process_iter(['pid', 'name', 'cpu_percent', 'memory_percent']):
    try:
        info = p.info
        _procs.append({
            'pid': info['pid'],
            'name': (info['name'] or '')[:30],
            'cpu': round(info['cpu_percent'] or 0, 1),
            'mem': round(info['memory_percent'] or 0, 1)
        })
    except (psutil.NoSuchProcess, psutil.AccessDenied):
        pass
_procs.sort(key=lambda x: x['cpu'], reverse=True)
_procs = _procs[:%d]
_top = {'PID': [p['pid'] for p in _procs],
        'Process': [p['name'] for p in _procs],
        'CPU %%%%': [p['cpu'] for p in _procs],
        'Mem %%%%': [p['mem'] for p in _procs]}
", n))
  py$`_top`
}

get_net_io <- function() {
  py_run_string("
import psutil
_net = psutil.net_io_counters()
_net_info = {'sent': round(_net.bytes_sent / (1024**2), 1),
             'recv': round(_net.bytes_recv / (1024**2), 1)}
")
  py$`_net_info`
}

# --- Build the app ---
quick_app(
  title = "System Monitor",
  dark = TRUE,

  layout = vstack(
    header(show_clock = TRUE),

    # Top row: gauges
    hstack(
      # CPU gauge
      vstack(
        static("[bold cyan]CPU[/bold cyan]", id = "cpu_label"),
        progress_bar(total = 100, progress = 0, show_eta = FALSE,
                     show_percentage = TRUE, id = "cpu_bar"),
        sparkline(data = rep(0, 30), id = "cpu_spark"),
        id = "cpu_panel"
      ),
      # Memory gauge
      vstack(
        static("[bold green]Memory[/bold green]", id = "mem_label"),
        progress_bar(total = 100, progress = 0, show_eta = FALSE,
                     show_percentage = TRUE, id = "mem_bar"),
        sparkline(data = rep(0, 30), id = "mem_spark"),
        id = "mem_panel"
      ),
      # Disk gauge
      vstack(
        static("[bold yellow]Disk[/bold yellow]", id = "disk_label"),
        progress_bar(total = 100, progress = 0, show_eta = FALSE,
                     show_percentage = TRUE, id = "disk_bar"),
        static("", id = "disk_info"),
        id = "disk_panel"
      ),
      # Network
      vstack(
        static("[bold magenta]Network[/bold magenta]", id = "net_label"),
        static("Sent: 0 MB", id = "net_sent"),
        static("Recv: 0 MB", id = "net_recv"),
        id = "net_panel"
      ),
      id = "gauges"
    ),

    rule(label = "Top Processes"),

    # Process table
    data_table(
      data.frame(PID = integer(0), Process = character(0),
                 `CPU %` = numeric(0), `Mem %` = numeric(0),
                 check.names = FALSE),
      id = "proc_table", cursor = "row", zebra_stripes = TRUE, sortable = TRUE
    ),

    # Status bar
    static("Initializing...", id = "status_bar"),

    footer(),
    id = "root"
  ),

  on_mount = function(event, state) {
    # Install psutil if needed
    tryCatch(ensure_psutil(), error = function(e) {
      notify(state$app, paste("psutil error:", conditionMessage(e)), severity = "error")
    })
    state$set(".cpu_history", rep(0, 30))
    state$set(".mem_history", rep(0, 30))
    state$set(".tick", 0L)
    # Start polling every 2 seconds
    set_interval(state$app, 2, "poll_stats")
    # Initial fetch
    set_timer(state$app, 0.2, "initial_fetch")
    state
  },

  on_timer = function(event, state) {
    if (event$timer_id %in% c("poll_stats", "initial_fetch")) {
      tryCatch({
        # CPU
        cpu <- get_cpu_percent()
        cpu_hist <- state$get(".cpu_history")
        cpu_hist <- c(cpu_hist[-1], cpu)
        state$set(".cpu_history", cpu_hist)
        update(state$app, "cpu_bar", progress = cpu)
        update(state$app, "cpu_spark", data = cpu_hist)

        # Memory
        mem <- get_memory()
        mem_pct <- mem$percent
        mem_hist <- state$get(".mem_history")
        mem_hist <- c(mem_hist[-1], mem_pct)
        state$set(".mem_history", mem_hist)
        update(state$app, "mem_bar", progress = mem_pct)
        update(state$app, "mem_spark", data = mem_hist)
        update(state$app, "mem_label",
               content = sprintf("[bold green]Memory[/bold green] %.1f / %.1f GB",
                                 mem$used, mem$total))

        # Disk
        disk <- get_disk()
        update(state$app, "disk_bar", progress = disk$percent)
        update(state$app, "disk_info",
               content = sprintf("%.1f / %.1f GB", disk$used, disk$total))

        # Network
        net <- get_net_io()
        update(state$app, "net_sent",
               content = sprintf("Sent: %.1f MB", net$sent))
        update(state$app, "net_recv",
               content = sprintf("Recv: %.1f MB", net$recv))

        # Processes
        top <- get_top_processes(15L)
        update(state$app, "proc_table", clear_data = TRUE)
        update(state$app, "proc_table", add_rows = top)

        # Status
        tick <- state$get(".tick", 0L) + 1L
        state$set(".tick", tick)
        update(state$app, "status_bar",
               content = sprintf("CPU: %.1f%% | Mem: %.1f%% | Disk: %.1f%% | Tick: %d",
                                 cpu, mem_pct, disk$percent, tick))
      }, error = function(e) {
        notify(state$app, paste("Poll error:", conditionMessage(e)), severity = "warning")
      })
    }
    state
  },

  bindings = list(
    binding("q", "quit_app", "Quit", priority = TRUE),
    binding("escape", "quit_app", "Quit", priority = TRUE),
    binding("d", "toggle_dark", "Dark mode", priority = TRUE)
  ),
  on_key = function(event, state) {
    if (event$key == "q" || event$key == "escape") return(quit(state))
    state
  },
  on_action = function(event, state) {
    if (event$value == "quit_app") return(quit(state))
    if (event$value == "toggle_dark") {
      dark_toggle(state$app)
    }
    state
  },

  css = paste0(
    tui_theme("dracula"),
    "
    #gauges { height: 12; padding: 0 1; }
    #cpu_panel, #mem_panel, #disk_panel, #net_panel {
      width: 1fr; height: 100%; padding: 0 1;
      border: round #6272a4;
    }
    #cpu_spark, #mem_spark { height: 3; }
    Sparkline { height: 3; }
    ProgressBar { height: 1; }
    #proc_table { height: 1fr; }
    #status_bar { height: 1; dock: bottom; background: #44475a;
                  color: #50fa7b; padding: 0 1; }
    Rule { margin: 0 1; }
    "
  )
)

message("--- System Monitor exited ---")
