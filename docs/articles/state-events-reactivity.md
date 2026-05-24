# State, Events, and Reactivity

This guide explains how rtui apps handle user interaction: the event
system that responds to clicks, key presses, and value changes; the
mutable state object that persists data across events; and the reactive
binding system that automatically updates widgets when state changes.

> **Terminal only:** All examples must be saved as `.R` files and run
> from a real terminal (`Rscript my_app.R`). rtui apps do **not** work
> in RStudio, R GUI, Jupyter, or any embedded R console.

## The event loop

When an rtui app is running, Textual captures user input and dispatches
events. Each event is routed to an R callback function that you provide.
The callback inspects the event, optionally modifies state, updates
widgets, and returns state to continue.

    User action -> Textual event -> Python handler -> R callback -> state

## Handler functions

Every handler has the same signature:

``` r
function(event, state) {
  # ... do things ...
  state
}
```

- **`event`**: A list describing what happened. Always has `$type` and
  `$widget_id`. Many events also have `$value`.
- **`state`**: A mutable `RtuiState` object. Your persistent store
  across all events.
- **Return value**: Must return `state` (or
  [`quit()`](https://orijitghosh.github.io/rtui/reference/quit.md) to
  exit).

## Available event types

Pass handlers to
[`tui_app()`](https://orijitghosh.github.io/rtui/reference/tui_app.md)
or
[`quick_app()`](https://orijitghosh.github.io/rtui/reference/quick_app.md):

``` r
quick_app(
  layout = ...,
  on_mount   = function(event, state) { ... },  # App started
  on_click   = function(event, state) { ... },  # Button press / item click
  on_change  = function(event, state) { ... },  # Widget value changed
  on_submit  = function(event, state) { ... },  # Enter pressed in Input
  on_key     = function(event, state) { ... },  # Any key pressed
  on_timer   = function(event, state) { ... },  # Timer fired
  on_action  = function(event, state) { ... },  # Key binding action
  on_screen_result = function(event, state) { ... }  # Screen dismissed
)
```

### on_mount

Fires once when the app starts, after the UI is rendered. Use it for
initialisation – loading data, setting initial state, starting timers:

``` r
on_mount = function(event, state) {
  state$set("count", 0L)
  state$set("data", load_my_data())
  set_interval(state$app, 1, "clock_tick")
  state
}
```

### on_click

Fires when a button is pressed or an item is clicked. `event$widget_id`
tells you which widget; `event$value` carries the click data.

``` r
on_click = function(event, state) {
  if (event$widget_id == "save_btn") {
    save_data(state$get("data"))
    notify(state$app, "Saved!", severity = "info")
  }
  state
}
```

### on_change

Fires when a widget’s value changes (input text, checkbox toggle, select
choice, slider move, etc.):

``` r
on_change = function(event, state) {
  if (event$widget_id == "search") {
    results <- filter_data(state$get("data"), event$value)
    state$set("filtered", results)
  }
  state
}
```

### on_submit

Fires when the user presses Enter in an
[`input()`](https://orijitghosh.github.io/rtui/reference/input.md)
widget:

``` r
on_submit = list(
  search_box = function(event, state) {
    run_search(event$value)
    state
  }
)
```

### on_key

Fires on any key press. `event$key` is the key name:

``` r
on_key = function(event, state) {
  if (event$key == "q") return(quit())
  if (event$key == "r") {
    # refresh data
    state$set("data", reload())
  }
  state
}
```

### on_timer

Fires when a timer triggers. `event$timer_id` identifies which timer:

``` r
on_timer = function(event, state) {
  if (event$timer_id == "clock_tick") {
    update(state$app, "clock", value = format(Sys.time(), "%H:%M:%S"))
  }
  state
}
```

### on_action

Fires when a key binding action is triggered. `event$value` is the
action name:

``` r
on_action = function(event, state) {
  if (event$value == "quit_app") return(quit())
  if (event$value == "toggle_dark") dark_toggle(state$app)
  if (event$value == "save") save_data(state)
  state
}
```

### on_screen_result

Fires when a pushed screen is dismissed with a result value:

``` r
on_screen_result = function(event, state) {
  if (isTRUE(event$value)) {
    # User confirmed
    perform_action(state)
  }
  state
}
```

## Per-widget-id routing

For `on_click`, `on_change`, and `on_submit`, you can pass a **named
list** instead of a single function. Each name is a widget id, and its
value is the handler for that specific widget:

``` r
on_click = list(
  save_btn = function(event, state) {
    save_data(state)
    notify(state$app, "Saved!")
    state
  },
  delete_btn = function(event, state) {
    confirm(state$app, "Delete this item?")
    state
  },
  .default = function(event, state) {
    # Catch-all for any other widget
    message("Clicked: ", event$widget_id)
    state
  }
)
```

The special `.default` key acts as a catch-all for widgets not
explicitly listed.

This pattern is cleaner than a long `if/else` chain and makes it easy to
see which widgets have handlers at a glance.

## State management

### The RtuiState object

State is an R6 object with a simple key-value API:

``` r
# Set a value
state$set("count", 42L)

# Get a value (with optional default)
state$get("count")          # 42
state$get("missing")        # NULL
state$get("missing", 0L)    # 0 (default)

# Access the running app
state$app                   # RtuiApp object

# Get all state as a list
state$as_list()
```

State persists across all events within a single app run. After the app
exits,
[`quick_app()`](https://orijitghosh.github.io/rtui/reference/quick_app.md)
returns the final state invisibly.

### Patterns for state

**Counter pattern:**

``` r
on_click = list(
  inc = function(event, state) {
    n <- state$get("n", 0L) + 1L
    state$set("n", n)
    update(state$app, "display", value = as.character(n))
    state
  }
)
```

**List/collection pattern:**

``` r
on_click = list(
  add_item = function(event, state) {
    items <- state$get("items", list())
    new_item <- list(
      id = length(items) + 1L,
      text = state$get("input_text", ""),
      done = FALSE
    )
    items <- c(items, list(new_item))
    state$set("items", items)
    refresh_display(state)
    state
  }
)
```

**Toggle pattern:**

``` r
on_click = list(
  toggle_btn = function(event, state) {
    is_on <- !isTRUE(state$get("is_on"))
    state$set("is_on", is_on)
    update(state$app, "toggle_btn",
           label = if (is_on) "ON" else "OFF")
    state
  }
)
```

## Reactive bindings

Reactive bindings eliminate manual
[`update()`](https://orijitghosh.github.io/rtui/reference/update.md)
calls. Instead of this:

``` r
# Manual approach -- every handler must call update()
on_click = list(
  inc = function(event, state) {
    n <- state$get("count", 0L) + 1L
    state$set("count", n)
    update(state$app, "display", value = as.character(n))  # tedious!
    state
  }
)
```

You declare the binding once:

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
      state  # display auto-updates!
    }
  )
)
```

Whenever `state$set("count", value)` is called, the `"display"` widget’s
value is automatically updated. No manual
[`update()`](https://orijitghosh.github.io/rtui/reference/update.md)
needed.

### Binding types

The
[`reactive()`](https://orijitghosh.github.io/rtui/reference/reactive.md)
function accepts three binding forms:

**1. Widget id (string)** – auto-update the widget’s value:

``` r
reactive(count = "counter_display")
# state$set("count", 42) -> update(app, "counter_display", value = "42")
```

**2. Formula** – transform the value:

``` r
reactive(
  temp = ~ update(.app, "temp_label",
                   content = paste0(.x, " degrees C"))
)
```

In formulas, `.x` is the new value, `.state` is the state object, and
`.app` is the running app.

**3. Function** – full control:

``` r
reactive(
  temperature = function(value, state, app) {
    update(app, "temp_display", value = paste0(value, "C"))
    if (value > 100) {
      notify(app, "Overheating!", severity = "warning")
    }
  }
)
```

### Multiple bindings per key

Bind one state key to several widgets:

``` r
reactive(
  score = list(
    "score_digits",    # update digits widget
    ~ update(.app, "score_label",
             content = paste("Score:", .x)),
    function(value, state, app) {
      if (value >= 100) {
        notify(app, "High score!", severity = "info")
      }
    }
  )
)
```

## Updating widgets

The [`update()`](https://orijitghosh.github.io/rtui/reference/update.md)
function modifies a widget by id. Different widgets support different
properties:

``` r
# Text content (text, static, markdown)
update(state$app, "msg", content = "New message")

# Value (input, digits, switch, text_area)
update(state$app, "counter", value = "42")

# Label (button, checkbox)
update(state$app, "btn", label = "New Label")

# Enable/disable any widget
update(state$app, "btn", disabled = TRUE)

# Show/hide any widget
update(state$app, "panel", display = FALSE)

# OptionList items
update(state$app, "my_list", items = c("New", "Items"))

# DataTable rows
update(state$app, "table", add_rows = as.list(new_df))
update(state$app, "table", clear_data = TRUE)

# Progress bar
update(state$app, "pb", progress = 75)
update(state$app, "pb", total = 200)

# Collapsible section
update(state$app, "section", collapsed = FALSE)
```

## Quitting the app

Return [`quit()`](https://orijitghosh.github.io/rtui/reference/quit.md)
from any handler to exit the app:

``` r
on_key = function(event, state) {
  if (event$key == "q") return(quit())
  state
}
```

You can pass a result value that becomes the return value of
`app$run()`:

``` r
# Return the final data
return(quit(state$get("selected_item")))
```

## Example: Interactive filter

Here’s a complete app that demonstrates state, events, and reactive
bindings working together:

``` r
library(rtui)

# Data to filter
all_items <- c("Apple", "Apricot", "Banana", "Blueberry", "Cherry",
               "Date", "Fig", "Grape", "Kiwi", "Lemon", "Mango")

quick_app(
  title = "Fruit Filter",
  layout = vstack(
    header(),
    input(placeholder = "Type to filter...", id = "search"),
    rule(),
    option_list(items = all_items, id = "results"),
    static(paste(length(all_items), "items"), id = "count"),
    footer()
  ),

  on_mount = function(event, state) {
    state$set("all_items", all_items)
    state
  },

  on_change = list(
    search = function(event, state) {
      term <- tolower(event$value)
      items <- state$get("all_items")
      if (nzchar(term)) {
        filtered <- items[grepl(term, tolower(items))]
      } else {
        filtered <- items
      }
      update(state$app, "results", items = filtered)
      update(state$app, "count",
             content = paste(length(filtered), "items"))
      state
    }
  ),

  on_change_list = list(
    results = function(event, state) {
      notify(state$app, paste("Selected:", event$value))
      state
    }
  ),

  bindings = list(
    binding("q", "quit_app", "Quit", priority = TRUE),
    binding("escape", "quit_app", "Quit", priority = TRUE)
  ),
  on_action = function(event, state) {
    if (event$value == "quit_app") return(quit())
    state
  },

  css = paste0(
    tui_theme("nord"),
    "
    #search { margin: 0 1; }
    #results { height: 1fr; }
    #count { height: 1; text-align: center; color: $text-muted; }
    "
  )
)
```

## Example: Multi-handler routing

This example shows per-widget-id routing for both click and change
events:

``` r
library(rtui)

quick_app(
  title = "Settings",
  layout = vstack(
    header(),
    static("[bold]Preferences[/bold]"),
    rule(),
    checkbox("Enable notifications", value = TRUE, id = "notif"),
    checkbox("Dark mode", value = TRUE, id = "dark"),
    select(c("English", "Spanish", "French"), id = "lang"),
    rule(),
    hstack(
      button("Save", id = "save"),
      button("Reset", id = "reset")
    ),
    static("", id = "status"),
    footer()
  ),

  on_change = list(
    notif = function(event, state) {
      state$set("notifications", event$value)
      update(state$app, "status",
             content = paste("Notifications:", event$value))
      state
    },
    dark = function(event, state) {
      dark_toggle(state$app, event$value)
      state
    },
    lang = function(event, state) {
      state$set("language", event$value)
      update(state$app, "status",
             content = paste("Language:", event$value))
      state
    }
  ),

  on_click = list(
    save = function(event, state) {
      notify(state$app, "Settings saved!", severity = "info")
      state
    },
    reset = function(event, state) {
      update(state$app, "notif", value = TRUE)
      update(state$app, "lang", value = "English")
      notify(state$app, "Settings reset", severity = "warning")
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
