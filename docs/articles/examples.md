# Example Gallery

rtui ships with 14 ready-to-run example apps in `inst/examples/`. Each
one is self-contained and demonstrates a progressively richer set of
features.

> **Terminal only:** Save as `.R` files and run from a real terminal
> with `Rscript`. These will **not** work in RStudio or R GUI.

## Running examples

``` r
# From inside the rtui project directory:
Rscript inst/examples/05-counter.R

# Or after installing the package:
system.file("examples", "05-counter.R", package = "rtui") |>
  source()
```

## 01 — Hello World

**Features:**
[`text()`](https://orijitghosh.github.io/rtui/reference/text.md),
[`box()`](https://orijitghosh.github.io/rtui/reference/box.md),
[`vstack()`](https://orijitghosh.github.io/rtui/reference/vstack.md),
key handler,
[`quit()`](https://orijitghosh.github.io/rtui/reference/quit.md).

The simplest possible rtui app — a styled greeting with a quit key.

``` r
library(rtui)

app <- tui_app(
  layout = vstack(
    box(
      text("Hello from rtui!", id = "greeting"),
      border = "round", title = "Welcome"
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
```

## 02 — List-Detail

**Features:**
[`list_view()`](https://orijitghosh.github.io/rtui/reference/list_view.md),
`on_change`,
[`update()`](https://orijitghosh.github.io/rtui/reference/update.md),
per-widget routing.

A master-detail pattern: select an item on the left, see its content on
the right.

## 03 — Data Table

**Features:**
[`data_table()`](https://orijitghosh.github.io/rtui/reference/data_table.md),
displaying data frames.

Pass any data.frame directly to
[`data_table()`](https://orijitghosh.github.io/rtui/reference/data_table.md)
for an interactive, scrollable table view.

## 04 — dfdiff Explorer

**Features:**
[`list_view()`](https://orijitghosh.github.io/rtui/reference/list_view.md),
[`static()`](https://orijitghosh.github.io/rtui/reference/static.md),
`on_mount`, state timestamps.

A more complete list-detail explorer with named sections and mount-time
state initialization.

## 05 — Reactive Counter

**Features:**
[`reactive()`](https://orijitghosh.github.io/rtui/reference/reactive.md)
bindings,
[`digits()`](https://orijitghosh.github.io/rtui/reference/digits.md),
[`button()`](https://orijitghosh.github.io/rtui/reference/button.md),
click handlers,
[`notify()`](https://orijitghosh.github.io/rtui/reference/notify.md).

The classic counter app — but with reactive bindings so
`state$set("count", n)` automatically updates the digit display.

``` r
library(rtui)

quick_app(
  title = "Counter",
  layout = vstack(
    header(),
    center(vstack(
      digits("0", id = "display"),
      hstack(
        button("-1", id = "dec"),
        button("Reset", id = "reset"),
        button("+1", id = "inc")
      )
    )),
    footer(),
    id = "root"
  ),
  reactive = reactive(count = "display"),
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
  )
)
```

## 06 — Contact Form

**Features:**
[`tui_form()`](https://orijitghosh.github.io/rtui/reference/tui_form.md),
[`input()`](https://orijitghosh.github.io/rtui/reference/input.md),
[`select()`](https://orijitghosh.github.io/rtui/reference/select.md),
[`checkbox()`](https://orijitghosh.github.io/rtui/reference/checkbox.md),
[`confirm()`](https://orijitghosh.github.io/rtui/reference/confirm.md)
dialog, `on_screen_result`.

A structured form with validation, confirmation dialog before
submission, and status feedback.

## 07 — Stopwatch

**Features:**
[`set_interval()`](https://orijitghosh.github.io/rtui/reference/set_interval.md),
[`clear_timer()`](https://orijitghosh.github.io/rtui/reference/clear_timer.md),
[`progress_bar()`](https://orijitghosh.github.io/rtui/reference/progress_bar.md),
[`log_view()`](https://orijitghosh.github.io/rtui/reference/log_view.md),
key bindings with
[`binding()`](https://orijitghosh.github.io/rtui/reference/binding.md).

Start/pause/reset stopwatch with lap tracking. Press Space to toggle,
`d` for dark mode.

## 08 — Tabbed Dashboard

**Features:**
[`tabs()`](https://orijitghosh.github.io/rtui/reference/tabs.md),
[`tab_pane()`](https://orijitghosh.github.io/rtui/reference/tab_pane.md),
[`data_table()`](https://orijitghosh.github.io/rtui/reference/data_table.md),
[`sparkline()`](https://orijitghosh.github.io/rtui/reference/sparkline.md),
[`plot_bar()`](https://orijitghosh.github.io/rtui/reference/plot_bar.md),
[`digits()`](https://orijitghosh.github.io/rtui/reference/digits.md),
[`tui_theme()`](https://orijitghosh.github.io/rtui/reference/tui_theme.md).

A three-tab sales dashboard with KPI cards, sparkline trends, a sortable
data table, and a bar chart — styled with the Catppuccin theme.

## 09 — Todo List

**Features:**
[`option_list()`](https://orijitghosh.github.io/rtui/reference/option_list.md),
`on_submit`, dynamic list updates,
[`confirm()`](https://orijitghosh.github.io/rtui/reference/confirm.md)
dialog, CRUD operations.

Add tasks by typing and pressing Enter, mark them done, delete with
confirmation, and clear all completed items.

## 10 — Chart Gallery

**Features:**
[`plot_bar()`](https://orijitghosh.github.io/rtui/reference/plot_bar.md),
[`plot_line()`](https://orijitghosh.github.io/rtui/reference/plot_line.md),
[`plot_scatter()`](https://orijitghosh.github.io/rtui/reference/plot_scatter.md),
[`plot_hist()`](https://orijitghosh.github.io/rtui/reference/plot_hist.md),
[`plot_heatmap()`](https://orijitghosh.github.io/rtui/reference/plot_heatmap.md),
tabs, Dracula theme.

Five chart types in a tabbed view, each with sample data.

## 11 — Screens & Modals

**Features:**
[`push_screen()`](https://orijitghosh.github.io/rtui/reference/push_screen.md),
[`pop_screen()`](https://orijitghosh.github.io/rtui/reference/pop_screen.md),
[`tui_screen()`](https://orijitghosh.github.io/rtui/reference/tui_screen.md),
[`confirm()`](https://orijitghosh.github.io/rtui/reference/confirm.md),
[`alert()`](https://orijitghosh.github.io/rtui/reference/alert.md),
screen results.

A multi-screen app with a settings modal (input, select, switch) that
returns results to the main screen.

## 12 — Reactive Dashboard

**Features:**
[`reactive()`](https://orijitghosh.github.io/rtui/reference/reactive.md)
with formula bindings,
[`set_interval()`](https://orijitghosh.github.io/rtui/reference/set_interval.md),
auto-updating sparklines,
[`log_view()`](https://orijitghosh.github.io/rtui/reference/log_view.md),
multiple reactive targets, Nord theme.

A simulated system monitor that updates CPU/memory/disk every 2 seconds.
Reactive formulas auto-update digits and progress bars. Warnings are
logged and notified.

``` r
reactive = reactive(
  cpu = list(
    ~ update(.app, "cpu_display", value = paste0(.x, "%")),
    ~ update(.app, "cpu_bar", progress = .x)
  ),
  mem = list(
    ~ update(.app, "mem_display", value = paste0(.x, "%")),
    ~ update(.app, "mem_bar", progress = .x)
  )
)
```

## 13 — Background Tasks

**Features:**
[`run_async()`](https://orijitghosh.github.io/rtui/reference/run_async.md),
[`cancel_async()`](https://orijitghosh.github.io/rtui/reference/cancel_async.md),
`on_task` handler,
[`log_view()`](https://orijitghosh.github.io/rtui/reference/log_view.md),
[`progress_bar()`](https://orijitghosh.github.io/rtui/reference/progress_bar.md),
error handling.

Launch background R processes without freezing the UI. Run a slow
computation, see results arrive asynchronously, or cancel a running
task.

``` r
# Run a background task
run_async(state$app, function() {
  Sys.sleep(3)
  42
}, name = "my_task")

# Handle completion
on_task = function(event, state) {
  if (event$widget_id == "__async_ok") {
    notify(state$app, paste("Result:", event$value))
  }
  state
}
```

## 14 — Hot Reload Development

**Features:**
[`dev_app()`](https://orijitghosh.github.io/rtui/reference/dev_app.md),
file watching, automatic restart.

A development tool that watches your `.R` file and restarts the TUI
whenever you save. Edit in your favourite editor, save, and see changes
instantly.

``` r
# Launch from terminal:
Rscript -e "rtui::dev_app('my_app.R')"
```

## Showcase apps

Beyond these examples, rtui includes 8 full showcase apps in `spikes/`:

| App             | Highlights                                  |
|-----------------|---------------------------------------------|
| Stock Tracker   | Live prices, candlestick charts, sparklines |
| System Monitor  | CPU/memory/disk gauges, process table       |
| Log Viewer      | Severity filter, search, pause/resume       |
| CSV Explorer    | Browse R datasets, 5 chart types            |
| ggplot Explorer | 8 ggplot2 plots rendered in terminal        |
| Pomodoro Timer  | Big-digit countdown, work/break cycles      |
| Git Dashboard   | Commit log, contributor charts              |
| Markdown Notes  | CRUD notes with live markdown preview       |

Run any showcase:

``` bash
Rscript spikes/showcase_pomodoro.R
```
