# Create a TUI application

**Important:** TUI apps must be run from a real terminal emulator
(Windows Terminal, iTerm2, Terminal.app, etc.). They will **not** work
in the RStudio console, R GUI, Jupyter, or any embedded R console. Save
your code as a `.R` file and run it with `Rscript`.

## Usage

``` r
tui_app(
  layout,
  on_mount = NULL,
  on_key = NULL,
  on_click = NULL,
  on_change = NULL,
  on_submit = NULL,
  on_timer = NULL,
  on_action = NULL,
  on_screen_result = NULL,
  on_quit = NULL,
  css = NULL,
  title = NULL,
  sub_title = NULL,
  dark = TRUE,
  bindings = NULL,
  reactive = NULL
)
```

## Arguments

- layout:

  A widget spec defining the app layout.

- on_mount:

  Callback for the mount event: `function(event, state)`.

- on_key:

  Callback for key events: `function(event, state)`.

- on_click:

  Callback for click/press events. Either a single function
  `function(event, state)`, or a **named list** of per-widget handlers
  (e.g. `list(save_btn = function(event, state) {...})`).

- on_change:

  Callback for value-change events. Same signature as `on_click` —
  single function or named list by widget id.

- on_submit:

  Callback for input submit events (Enter in an Input). Single function
  or named list by widget id.

- on_timer:

  Callback for timer events: `function(event, state)`. `event$timer_id`
  identifies which timer fired.

- on_action:

  Callback for action events from key bindings: `function(event, state)`
  where `event$value` is the action name.

- on_screen_result:

  Callback for screen dismiss results: `function(event, state)` where
  `event$value` is the result.

- on_quit:

  Callback for quit event: `function(event, state)`.

- css:

  Optional Textual CSS string.

- title:

  Optional app title (shown in header).

- sub_title:

  Optional app subtitle (shown in header).

- dark:

  Whether to use dark mode (default TRUE).

- bindings:

  Optional list of key bindings created with
  [`binding()`](https://orijitghosh.github.io/rtui/reference/binding.md).
  Bindings are shown in the footer and dispatch `"action"` events.

- reactive:

  Optional reactive bindings created with
  [`reactive()`](https://orijitghosh.github.io/rtui/reference/reactive.md).
  Auto-updates widgets when state values change.

## Value

An `RtuiApp` R6 object.
