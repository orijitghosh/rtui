# Advanced Features

This guide covers rtui’s advanced capabilities: screens and modal
dialogs, timers and workers, key bindings, the command palette,
structured forms, and the deferred loading pattern.

> **Terminal only:** All examples must be saved as `.R` files and run
> from a real terminal (`Rscript my_app.R`). rtui apps do **not** work
> in RStudio, R GUI, Jupyter, or any embedded R console.

## Screens

Screens let you build multi-page apps. You push a screen onto the stack
to show it, and pop it to return to the previous screen. Screens can
return result values to the caller.

### Creating a screen

A screen is a layout with optional CSS:

``` r
my_screen <- tui_screen(
  layout = vstack(
    static("[bold]Detail View[/bold]"),
    text("Some detailed content", id = "detail_text"),
    hstack(
      button("OK", id = "__dlg_yes"),
      button("Cancel", id = "__dlg_no")
    )
  ),
  css = "
    #detail_text { padding: 2; }
    Button { margin: 0 1; }
  "
)
```

### Pushing and popping

Push a screen from any handler. The screen replaces the current view but
the main app is preserved underneath:

``` r
on_click = list(
  show_detail = function(event, state) {
    push_screen(state$app, my_screen)
    state
  }
)
```

The screen is automatically dismissed when the user clicks `__dlg_yes`
(result `TRUE`) or `__dlg_no` (result `FALSE`). Handle the result:

``` r
on_screen_result = function(event, state) {
  if (isTRUE(event$value)) {
    notify(state$app, "Confirmed!")
  } else {
    notify(state$app, "Cancelled.")
  }
  state
}
```

### Built-in dialogs

For common cases, rtui provides [`confirm()`](../reference/confirm.md)
and [`alert()`](../reference/alert.md) which build and push a styled
dialog screen in one call:

``` r
# Confirmation dialog (Yes/No)
on_click = list(
  delete_btn = function(event, state) {
    confirm(state$app, "Delete this item?", title = "Delete")
    state
  }
),
on_screen_result = function(event, state) {
  if (isTRUE(event$value)) {
    # user confirmed deletion
    delete_item(state)
    notify(state$app, "Deleted!", severity = "warning")
  }
  state
}
```

``` r
# Alert dialog (OK only)
alert(state$app, "Operation completed!", title = "Success")
```

Customise button labels:

``` r
confirm(state$app,
        "Save changes before closing?",
        title = "Unsaved Changes",
        yes_label = "Save",
        no_label = "Discard")
```

### Multi-step wizards

Chain screens to build wizard-style flows:

``` r
step1 <- tui_screen(
  layout = center(middle(vstack(
    static("[bold]Step 1: Choose Type[/bold]"),
    select(c("Report", "Dashboard", "Form"), id = "type_select"),
    button("Next", id = "__dlg_yes")
  )))
)

on_click = list(
  start_wizard = function(event, state) {
    state$set("wizard_step", 1L)
    push_screen(state$app, step1)
    state
  }
),
on_screen_result = function(event, state) {
  step <- state$get("wizard_step", 0L)
  if (step == 1L && !is.null(event$value)) {
    state$set("chosen_type", event$value)
    state$set("wizard_step", 2L)
    # push step 2...
  }
  state
}
```

## Timers

Timers let you schedule actions – updating a clock, polling data,
running animations, or implementing timeouts.

### One-shot timer

Fires once after a delay:

``` r
# Fire after 2 seconds
set_timer(state$app, 2, "delayed_action")

# Handle it
on_timer = function(event, state) {
  if (event$timer_id == "delayed_action") {
    notify(state$app, "Timer fired!")
  }
  state
}
```

### Repeating interval

Fires repeatedly at a fixed interval:

``` r
# Fire every 1 second
set_interval(state$app, 1, "tick")

on_timer = function(event, state) {
  if (event$timer_id == "tick") {
    update(state$app, "clock",
           value = format(Sys.time(), "%H:%M:%S"))
  }
  state
}
```

### Cancelling timers

``` r
clear_timer(state$app, "tick")
```

### Deferred loading pattern

A common pattern is to defer heavy work so the UI renders first. Use a
short one-shot timer:

``` r
on_mount = function(event, state) {
  # Show "Loading..." immediately
  update(state$app, "status", content = "Loading data...")

  # Defer the heavy work
  set_timer(state$app, 0.1, "load_data")
  state
},

on_timer = function(event, state) {
  if (event$timer_id == "load_data") {
    # This runs after the UI has painted
    data <- expensive_data_load()
    state$set("data", data)
    update(state$app, "table", add_rows = as.list(data))
    update(state$app, "status", content = "Ready.")
  }
  state
}
```

## Workers

Workers are convenience wrappers around
[`set_interval()`](../reference/set_interval.md) for background polling
patterns:

``` r
# Start polling every 5 seconds
set_worker(state$app, interval = 5, name = "data_poll")

# Stop polling
cancel_worker(state$app, "data_poll")
```

Workers fire `"timer"` events just like intervals, so handle them in
`on_timer` with the worker name as `event$timer_id`.

### Progress tracking pattern

``` r
on_mount = function(event, state) {
  state$set("progress", 0L)
  set_worker(state$app, 0.5, "progress_worker")
  state
},

on_timer = function(event, state) {
  if (event$timer_id == "progress_worker") {
    p <- state$get("progress", 0L) + 5L
    state$set("progress", p)
    update(state$app, "pb", progress = p)

    if (p >= 100L) {
      cancel_worker(state$app, "progress_worker")
      notify(state$app, "Complete!", severity = "info")
    }
  }
  state
}
```

## Key bindings

Key bindings map keyboard shortcuts to named actions. They are shown
automatically in the [`footer()`](../reference/footer.md) widget.

### Defining bindings

``` r
bindings = list(
  binding("q",      "quit_app",    "Quit"),
  binding("ctrl+s", "save",        "Save",      priority = TRUE),
  binding("ctrl+n", "new",         "New",       priority = TRUE),
  binding("f1",     "show_help",   "Help"),
  binding("d",      "toggle_dark", "Dark mode", priority = TRUE)
)
```

Parameters:

- **`key`**: The key or key combination (`"q"`, `"ctrl+s"`, `"f1"`,
  `"escape"`, `"up"`, `"down"`, etc.)
- **`action`**: A string identifier dispatched as `event$value` in
  `on_action`
- **`description`**: Human-readable text shown in the footer
- **`priority`**: If `TRUE`, the binding fires even when a text input
  has focus. Use for global shortcuts like quit and save.

### Handling actions

``` r
on_action = function(event, state) {
  switch(event$value,
    quit_app    = return(quit()),
    save        = { save_data(state); notify(state$app, "Saved!") },
    new         = create_new_item(state),
    show_help   = alert(state$app, "Press q to quit, Ctrl+S to save."),
    toggle_dark = dark_toggle(state$app)
  )
  state
}
```

## Command palette

The command palette is a searchable pop-up menu opened with `Ctrl+P`.
Register custom commands that dispatch action events:

``` r
on_mount = function(event, state) {
  register_commands(state$app, list(
    command("Reset All Data", "reset_data",
            "Clear all data and start fresh"),
    command("Export to CSV", "export_csv",
            "Save current data as CSV file"),
    command("Toggle Dark Mode", "toggle_dark",
            "Switch between dark and light themes"),
    command("Show Statistics", "show_stats",
            "Display summary statistics")
  ))
  state
}
```

Commands are searched by name in the palette. When selected, the
command’s `action` is dispatched to `on_action`:

``` r
on_action = function(event, state) {
  if (event$value == "reset_data") {
    confirm(state$app, "Reset all data?")
  } else if (event$value == "export_csv") {
    write.csv(state$get("data"), "export.csv")
    notify(state$app, "Exported to export.csv")
  } else if (event$value == "toggle_dark") {
    dark_toggle(state$app)
  } else if (event$value == "show_stats") {
    data <- state$get("data")
    alert(state$app, paste("Rows:", nrow(data), "\nCols:", ncol(data)))
  }
  state
}
```

## Forms

[`tui_form()`](../reference/tui_form.md) builds structured input forms
with labelled fields and a submit button:

``` r
library(rtui)

quick_app(
  title = "Registration",
  layout = vstack(
    header(),
    tui_form(
      Name = input(placeholder = "Your full name"),
      Email = input(placeholder = "you@example.com"),
      Department = select(c("Engineering", "Marketing", "Sales", "HR")),
      `Receive Updates` = checkbox("Send me email updates", value = TRUE),
      id = "reg_form"
    ),
    static("", id = "result"),
    footer()
  ),

  on_click = list(
    `__form_submit` = function(event, state) {
      # Collect all form values
      vals <- collect_form(state$app, c("name", "email",
                                         "department", "receive_updates"))
      msg <- paste(
        "Name:", vals$name,
        "\nEmail:", vals$email,
        "\nDept:", vals$department,
        "\nUpdates:", vals$receive_updates
      )
      update(state$app, "result", content = msg)
      notify(state$app, "Form submitted!", severity = "info")
      state
    }
  ),

  bindings = list(binding("q", "quit_app", "Quit", priority = TRUE)),
  on_action = function(event, state) {
    if (event$value == "quit_app") return(quit())
    state
  }
)
```

### How forms work

1.  Field names become both labels and widget ids (lowercased, spaces to
    underscores)
2.  The form auto-generates a `"__form_submit"` button
3.  Handle the button click with `on_click` and use
    [`collect_form()`](../reference/collect_form.md) to gather all
    current values

### Custom field ids

If a field spec already has an id, it keeps that id instead of the
auto-generated one:

``` r
tui_form(
  Name = input(placeholder = "Name", id = "user_name"),
  Notes = text_area(value = "", id = "user_notes")
)
```

## Dark mode

Toggle between dark and light mode:

``` r
# Start in light mode
quick_app(dark = FALSE, ...)

# Toggle at runtime
dark_toggle(state$app)

# Set explicitly
dark_toggle(state$app, dark = TRUE)
dark_toggle(state$app, dark = FALSE)
```

## Clipboard

Copy text to the system clipboard:

``` r
copy_to_clipboard(state$app, "Text to copy")
notify(state$app, "Copied to clipboard!")
```

## Notifications

Show transient toast notifications:

``` r
notify(state$app, "Operation successful", severity = "info")
notify(state$app, "Check your input", severity = "warning")
notify(state$app, "Connection failed!", severity = "error")
```

## Log view

The [`log_view()`](../reference/log_view.md) widget creates an
append-only scrolling log, useful for status messages, debug output, or
activity feeds:

``` r
log_view(id = "activity_log", max_lines = 500)

# Write plain text
log_write(state$app, "activity_log", "User logged in")

# Write with Rich markup for colours
log_write(state$app, "activity_log",
          "[green]OK[/green] Connected to server",
          markup = TRUE)

log_write(state$app, "activity_log",
          "[bold red]ERROR[/bold red] Connection timeout",
          markup = TRUE)
```

## Putting it all together

Here is a complete app that uses screens, timers, key bindings, the
command palette, and forms together:

``` r
library(rtui)

quick_app(
  title = "Task Manager",

  layout = vstack(
    header(),
    hstack(
      vstack(
        static("[bold]Tasks[/bold]"),
        option_list(items = character(0), id = "task_list"),
        hstack(
          button("+ Add", id = "add_btn"),
          button("Delete", id = "del_btn")
        ),
        id = "sidebar"
      ),
      vstack(
        static("Select a task or add a new one.", id = "detail"),
        progress_bar(total = 100, progress = 0, id = "overall_pb"),
        static("0% complete", id = "progress_label"),
        id = "main"
      )
    ),
    footer()
  ),

  on_mount = function(event, state) {
    state$set("tasks", list())
    register_commands(state$app, list(
      command("Add Task", "add_task", "Create a new task"),
      command("Clear All", "clear_all", "Remove all tasks"),
      command("Toggle Dark", "toggle_dark", "Switch theme")
    ))
    state
  },

  on_click = list(
    add_btn = function(event, state) {
      # Push an input screen
      screen <- tui_screen(
        layout = center(middle(vstack(
          static("[bold]New Task[/bold]", id = "__dlg_title"),
          input(placeholder = "Task description...", id = "__dlg_input"),
          hstack(
            button("Add", id = "__dlg_yes"),
            button("Cancel", id = "__dlg_no")
          ),
          id = "__dlg_content"
        ))),
        css = paste0(
          "#__dlg_content { width: 50; border: heavy $accent; ",
          "padding: 1 2; background: $surface; } ",
          "Button { margin: 0 1; }"
        )
      )
      push_screen(state$app, screen)
      state
    },
    del_btn = function(event, state) {
      tasks <- state$get("tasks", list())
      if (length(tasks) > 0) {
        confirm(state$app, "Delete the last task?")
        state$set("delete_pending", TRUE)
      }
      state
    }
  ),

  on_screen_result = function(event, state) {
    if (isTRUE(state$get("delete_pending"))) {
      state$set("delete_pending", FALSE)
      if (isTRUE(event$value)) {
        tasks <- state$get("tasks", list())
        tasks[[length(tasks)]] <- NULL
        state$set("tasks", tasks)
        refresh_tasks(state)
      }
    } else if (is.character(event$value) && nzchar(event$value)) {
      # New task added
      tasks <- state$get("tasks", list())
      tasks <- c(tasks, list(list(text = event$value, done = FALSE)))
      state$set("tasks", tasks)
      refresh_tasks(state)
      notify(state$app, paste("Added:", event$value))
    }
    state
  },

  on_action = function(event, state) {
    if (event$value == "quit_app") return(quit())
    if (event$value == "toggle_dark") dark_toggle(state$app)
    if (event$value == "clear_all") {
      state$set("tasks", list())
      refresh_tasks(state)
    }
    state
  },

  bindings = list(
    binding("q", "quit_app", "Quit", priority = TRUE),
    binding("a", "add_task", "Add", priority = TRUE),
    binding("d", "toggle_dark", "Dark", priority = TRUE)
  ),

  css = paste0(
    tui_theme("nord"),
    "
    #sidebar { width: 35; padding: 1; border-right: tall $accent; }
    #main { width: 1fr; padding: 1; }
    #task_list { height: 1fr; }
    #overall_pb { margin: 1 0; }
    Button { margin: 0 1; }
    "
  )
)

# Helper function (define before quick_app call!)
refresh_tasks <- function(state) {
  tasks <- state$get("tasks", list())
  items <- vapply(tasks, function(t) {
    paste(if (t$done) "[x]" else "[ ]", t$text)
  }, character(1))
  if (length(items) == 0) items <- "(no tasks)"
  update(state$app, "task_list", items = items)
  n <- length(tasks)
  done <- sum(vapply(tasks, function(t) t$done, logical(1)))
  pct <- if (n > 0) round(done / n * 100) else 0
  update(state$app, "overall_pb", progress = pct)
  update(state$app, "progress_label",
         content = sprintf("%d/%d tasks done (%d%%)", done, n, pct))
}
```

> **Important**: Helper functions like `refresh_tasks()` must be defined
> *before* the [`quick_app()`](../reference/quick_app.md) call, because
> [`quick_app()`](../reference/quick_app.md) runs the app immediately.
