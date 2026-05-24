# rtui

> Full-screen terminal user interfaces from R — powered by Python’s
> [Textual](https://textual.textualize.io/) framework.

[**Documentation**](https://orijitghosh.github.io/rtui/) \| [Example
Gallery](https://orijitghosh.github.io/rtui/articles/examples.html) \|
[Getting
Started](https://orijitghosh.github.io/rtui/articles/getting-started.html)

**rtui** gives R users 35+ widgets, 12 chart types, CSS-like styling,
reactive state, screens, timers, key bindings, a command palette, and 10
built-in themes — all without writing a single line of Python. Under the
hood it uses [reticulate](https://rstudio.github.io/reticulate/) to
bridge R and Textual in a single process.

------------------------------------------------------------------------

## Features

| Category | Highlights |
|----|----|
| **Widgets** | Button, Input, TextArea, Select, Checkbox, Switch, RadioSet, DataTable, OptionList, SelectionList, Tabs, Tree, DirectoryTree, ProgressBar, Sparkline, Digits, Markdown, RichLog, Loading, Rule, and more |
| **Layouts** | [`vstack()`](https://orijitghosh.github.io/rtui/reference/vstack.md), [`hstack()`](https://orijitghosh.github.io/rtui/reference/hstack.md), [`grid()`](https://orijitghosh.github.io/rtui/reference/grid.md), [`center()`](https://orijitghosh.github.io/rtui/reference/center.md), [`middle()`](https://orijitghosh.github.io/rtui/reference/middle.md), [`scroll()`](https://orijitghosh.github.io/rtui/reference/scroll.md), [`collapsible()`](https://orijitghosh.github.io/rtui/reference/collapsible.md), [`tabs()`](https://orijitghosh.github.io/rtui/reference/tabs.md) |
| **Charts** | 12 chart types via plotext — bar, line, scatter, histogram, box, heatmap, candlestick, stacked/grouped bar, and more. Plus [`plot_ggplot()`](https://orijitghosh.github.io/rtui/reference/plot_ggplot.md) to render ggplot2 objects in the terminal |
| **State** | Mutable [`tui_state()`](https://orijitghosh.github.io/rtui/reference/tui_state.md) with reactive bindings that auto-update widgets |
| **Screens** | [`push_screen()`](https://orijitghosh.github.io/rtui/reference/push_screen.md) / [`pop_screen()`](https://orijitghosh.github.io/rtui/reference/pop_screen.md) for multi-page apps and modal dialogs |
| **Dialogs** | Built-in [`confirm()`](https://orijitghosh.github.io/rtui/reference/confirm.md) and [`alert()`](https://orijitghosh.github.io/rtui/reference/alert.md) modal dialogs |
| **Timers** | [`set_timer()`](https://orijitghosh.github.io/rtui/reference/set_timer.md), [`set_interval()`](https://orijitghosh.github.io/rtui/reference/set_interval.md), [`clear_timer()`](https://orijitghosh.github.io/rtui/reference/clear_timer.md) for animations and polling |
| **Key bindings** | Declarative [`binding()`](https://orijitghosh.github.io/rtui/reference/binding.md) objects shown in the footer |
| **Command palette** | `Ctrl+P` command palette with custom commands via [`register_commands()`](https://orijitghosh.github.io/rtui/reference/register_commands.md) |
| **Themes** | 10 built-in colour themes (Dracula, Nord, Monokai, Gruvbox, Catppuccin, and more) |
| **Convenience** | [`quick_app()`](https://orijitghosh.github.io/rtui/reference/quick_app.md) for one-call apps, [`data_viewer()`](https://orijitghosh.github.io/rtui/reference/data_viewer.md) for instant data exploration, `file_browser()` for directory browsing |

------------------------------------------------------------------------

## Installation

``` r
# Install the R package (from source)
devtools::install_local("path/to/rtui")

# Install Python dependencies (one-time setup)
rtui::install_python_deps()
```

**Requirements:** R \>= 4.1, Python \>= 3.9 (not Microsoft Store Python
on Windows).

> **Important: rtui apps must be run from a real terminal** (Windows
> Terminal, iTerm2, Terminal.app, or any xterm-compatible terminal).
> They will **not** work in the RStudio console, R GUI, Jupyter
> notebooks, or any embedded console. Save your code as a `.R` file and
> run it with `Rscript`.

### Windows setup

``` r
# Point reticulate to the rtui virtualenv
Sys.setenv(RETICULATE_PYTHON_ENV = "r-rtui")
library(reticulate)
use_virtualenv("r-rtui", required = TRUE)
```

------------------------------------------------------------------------

## Quick start

> **Reminder:** All examples below must be saved as `.R` files and run
> from a real terminal with `Rscript my_app.R`. They will not work from
> RStudio or R GUI.

### Hello world

``` r
library(rtui)

quick_app(
  title = "Hello",
  layout = center(
    middle(
      text("Hello from rtui!")
    )
  )
)
```

### One-liner data explorer

``` r
data_viewer(mtcars)
```

Opens an interactive, scrollable, sortable data table. Press `q` to
quit.

### Counter app

``` r
library(rtui)

quick_app(
  title = "Counter",
  layout = vstack(
    header(),
    center(middle(vstack(
      digits("0", id = "count"),
      hstack(
        button("-1", id = "dec"),
        button("+1", id = "inc"),
        button("Reset", id = "reset")
      )
    ))),
    footer()
  ),

  on_click = list(
    inc = function(event, state) {
      n <- state$get("n", 0L) + 1L
      state$set("n", n)
      update(state$app, "count", value = as.character(n))
      state
    },
    dec = function(event, state) {
      n <- state$get("n", 0L) - 1L
      state$set("n", n)
      update(state$app, "count", value = as.character(n))
      state
    },
    reset = function(event, state) {
      state$set("n", 0L)
      update(state$app, "count", value = "0")
      state
    }
  ),

  bindings = list(
    binding("q", "quit_app", "Quit", priority = TRUE)
  ),
  on_action = function(event, state) {
    if (event$value == "quit_app") return(quit())
    state
  }
)
```

------------------------------------------------------------------------

## Examples

rtui ships with 12 runnable examples in `inst/examples/`:

| Example | Features |
|----|----|
| **01-hello** | Minimal app — text, box, key handler |
| **02-list-detail** | Master-detail with list_view and update() |
| **03-data-table** | Interactive data.frame table |
| **04-dfdiff-explorer** | List-detail with mount state |
| **05-counter** | Reactive bindings, digits, buttons |
| **06-form** | tui_form(), confirm dialog, validation |
| **07-timer** | Stopwatch with set_interval, progress bar, laps |
| **08-tabs-dashboard** | Tabs, KPI cards, sparklines, charts, themes |
| **09-todo** | CRUD todo list with confirm delete |
| **10-charts** | Chart gallery — bar, line, scatter, histogram, heatmap |
| **11-screens-modal** | push_screen, pop_screen, settings modal |
| **12-reactive-dashboard** | Reactive formulas, auto-updating sparklines, timers |

``` powershell
Rscript inst/examples/05-counter.R
```

------------------------------------------------------------------------

## Showcase apps

rtui ships with 8 demo apps in `spikes/` that demonstrate real-world
usage:

| App | Description |
|----|----|
| **Stock Tracker** | Live (simulated) stock prices, candlestick charts, sparklines |
| **System Monitor** | Real-time CPU, memory, disk usage with sparklines and process table |
| **Log Viewer** | Coloured log output with severity filter, search, and pause/resume |
| **CSV Explorer** | Browse R datasets with sortable tables and 5 chart types |
| **ggplot Explorer** | 8 ggplot2 examples rendered as terminal charts, command palette |
| **Pomodoro Timer** | Big-digit countdown, work/break cycles, session history |
| **Git Dashboard** | Commit log, file type stats, contributor charts for any git repo |
| **Markdown Notes** | Create, edit, search, and delete notes with live markdown preview |

Run any showcase from a real terminal:

``` powershell
# Windows
& "C:\Program Files\R\R-4.4.3\bin\Rscript.exe" spikes/showcase_pomodoro.R

# macOS/Linux
Rscript spikes/showcase_pomodoro.R
```

------------------------------------------------------------------------

## Concepts

### Layout

Layouts are built with container functions that accept child widgets:

| Function           | Description                    |
|--------------------|--------------------------------|
| `vstack(...)`      | Stack children vertically      |
| `hstack(...)`      | Stack children horizontally    |
| `grid(...)`        | CSS grid layout                |
| `center(...)`      | Center horizontally            |
| `middle(...)`      | Center vertically              |
| `scroll(...)`      | Scrollable container           |
| `box(child)`       | Container with optional border |
| `collapsible(...)` | Collapsible section with title |
| `tabs(...)`        | Tabbed content container       |

### Widgets

**Display:**
[`text()`](https://orijitghosh.github.io/rtui/reference/text.md),
[`static()`](https://orijitghosh.github.io/rtui/reference/static.md),
[`markdown()`](https://orijitghosh.github.io/rtui/reference/markdown.md),
[`digits()`](https://orijitghosh.github.io/rtui/reference/digits.md),
[`pretty_table()`](https://orijitghosh.github.io/rtui/reference/pretty_table.md),
[`sparkline()`](https://orijitghosh.github.io/rtui/reference/sparkline.md),
[`progress_bar()`](https://orijitghosh.github.io/rtui/reference/progress_bar.md),
[`rule()`](https://orijitghosh.github.io/rtui/reference/rule.md),
[`loading()`](https://orijitghosh.github.io/rtui/reference/loading.md),
[`placeholder()`](https://orijitghosh.github.io/rtui/reference/placeholder.md),
[`log_view()`](https://orijitghosh.github.io/rtui/reference/log_view.md)

**Input:**
[`input()`](https://orijitghosh.github.io/rtui/reference/input.md),
[`button()`](https://orijitghosh.github.io/rtui/reference/button.md),
[`checkbox()`](https://orijitghosh.github.io/rtui/reference/checkbox.md),
[`switch_input()`](https://orijitghosh.github.io/rtui/reference/switch_input.md),
[`select()`](https://orijitghosh.github.io/rtui/reference/select.md),
[`radio_set()`](https://orijitghosh.github.io/rtui/reference/radio_set.md),
[`radio_button()`](https://orijitghosh.github.io/rtui/reference/radio_button.md),
[`text_area()`](https://orijitghosh.github.io/rtui/reference/text_area.md),
[`masked_input()`](https://orijitghosh.github.io/rtui/reference/masked_input.md),
[`option_list()`](https://orijitghosh.github.io/rtui/reference/option_list.md),
[`selection_list()`](https://orijitghosh.github.io/rtui/reference/selection_list.md),
[`list_view()`](https://orijitghosh.github.io/rtui/reference/list_view.md),
[`data_table()`](https://orijitghosh.github.io/rtui/reference/data_table.md)

**Navigation:**
[`header()`](https://orijitghosh.github.io/rtui/reference/header.md),
[`footer()`](https://orijitghosh.github.io/rtui/reference/footer.md),
[`tabs()`](https://orijitghosh.github.io/rtui/reference/tabs.md),
[`tab_pane()`](https://orijitghosh.github.io/rtui/reference/tab_pane.md),
[`collapsible()`](https://orijitghosh.github.io/rtui/reference/collapsible.md),
[`content_switcher()`](https://orijitghosh.github.io/rtui/reference/content_switcher.md),
[`tree()`](https://orijitghosh.github.io/rtui/reference/tree.md),
[`directory_tree()`](https://orijitghosh.github.io/rtui/reference/directory_tree.md)

### Events & handlers

Handlers are `function(event, state)` that return `state`:

``` r
tui_app(
  ...,
  on_mount   = function(event, state) { ... },  # App started
  on_click   = function(event, state) { ... },  # Button/item click
  on_change  = function(event, state) { ... },  # Value changed
  on_key     = function(event, state) { ... },  # Key pressed
  on_submit  = function(event, state) { ... },  # Enter in Input
  on_timer   = function(event, state) { ... },  # Timer fired
  on_action  = function(event, state) { ... },  # Key binding action
  on_screen_result = function(event, state) { ... }  # Screen dismissed
)
```

**Per-widget-id routing** — pass a named list instead of a function:

``` r
on_click = list(
  save_btn   = function(event, state) { ... },
  cancel_btn = function(event, state) { ... },
  .default   = function(event, state) { ... }   # catch-all
)
```

### State

State is a mutable key-value store passed to every handler:

``` r
state$set("count", 10)
state$get("count")        # 10
state$get("missing", 0)   # 0 (default)
state$app                  # the running app (for update/notify)
```

### Reactive bindings

Skip manual
[`update()`](https://orijitghosh.github.io/rtui/reference/update.md)
calls — bind state keys to widgets:

``` r
quick_app(
  layout = vstack(
    digits("0", id = "display"),
    button("+1", id = "inc"),
    id = "root"
  ),
  reactive = reactive(count = "display"),
  on_click = list(
    inc = function(event, state) {
      state$set("count", state$get("count", 0L) + 1L)
      state
    }
  )
)
```

### Updating widgets

``` r
update(app, "widget_id", content = "new text")  # text, static, markdown
update(app, "widget_id", value = "new value")   # input, digits, switch
update(app, "widget_id", label = "new label")   # button, checkbox
update(app, "widget_id", disabled = TRUE)        # any widget
update(app, "widget_id", display = FALSE)        # show/hide
```

### Charts

12 chart types with `plot_*()` functions:

``` r
# Bar chart
plot_bar(app, "chart_id",
         labels = c("A", "B", "C"),
         values = c(10, 25, 15),
         title = "Sales", color = "cyan")

# Render a ggplot2 object in the terminal
library(ggplot2)
p <- ggplot(mtcars, aes(wt, mpg)) + geom_point() + geom_smooth()
plot_ggplot(app, "chart_id", p)
```

Available:
[`plot_bar()`](https://orijitghosh.github.io/rtui/reference/plot_bar.md),
[`plot_line()`](https://orijitghosh.github.io/rtui/reference/plot_line.md),
[`plot_scatter()`](https://orijitghosh.github.io/rtui/reference/plot_scatter.md),
`plot_histogram()`,
[`plot_box()`](https://orijitghosh.github.io/rtui/reference/plot_box.md),
[`plot_heatmap()`](https://orijitghosh.github.io/rtui/reference/plot_heatmap.md),
[`plot_candlestick()`](https://orijitghosh.github.io/rtui/reference/plot_candlestick.md),
[`plot_stacked_bar()`](https://orijitghosh.github.io/rtui/reference/plot_stacked_bar.md),
[`plot_multiple_bar()`](https://orijitghosh.github.io/rtui/reference/plot_multiple_bar.md),
`plot_pie()`, `plot_area()`, `plot_table()`

### Themes

``` r
# Apply a built-in theme
css = tui_theme("dracula")

# List all themes
list_themes()
#> "dracula" "nord" "monokai" "solarized_dark" "solarized_light"
#> "gruvbox" "catppuccin" "ocean" "forest" "sunset"
```

### Screens and dialogs

``` r
# One-line confirmation dialog
confirm(state$app, "Delete this item?")

# Handle the result
on_screen_result = function(event, state) {
  if (isTRUE(event$value)) {
    # user confirmed
  }
  state
}
```

### Timers

``` r
set_timer(state$app, 2, "my_timer")     # One-shot (2 seconds)
set_interval(state$app, 1, "tick")      # Repeating (every 1 second)
clear_timer(state$app, "tick")           # Cancel
```

### Command palette

``` r
register_commands(state$app, list(
  command("Reset Data", "reset", "Clear all data"),
  command("Export CSV", "export", "Save to CSV file")
))
```

Press `Ctrl+P` to open the palette.

------------------------------------------------------------------------

## Architecture

    R (your app code)
      │
      ├── quick_app() / tui_app()       ← layout specs (nested R lists)
      ├── RtuiApp R6 class              ← state, event dispatch
      └── reticulate bridge
            ↓
    Python (rtui_shim)
      ├── app.py    ← Textual App subclass, widget tree, event routing
      └── factory.py ← maps spec "kind" → Textual widget class

Event flow: **Textual event → Python handler → R callback →
[`update()`](https://orijitghosh.github.io/rtui/reference/update.md) →
Python applies patches**

------------------------------------------------------------------------

## Convenience functions

| Function             | Description                     |
|----------------------|---------------------------------|
| `quick_app(...)`     | Build + run in one call         |
| `data_viewer(df)`    | Interactive data.frame explorer |
| `browse_files(path)` | Terminal file browser           |

------------------------------------------------------------------------

## License

MIT
