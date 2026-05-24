# Define reactive bindings between state keys and widgets

Reactive bindings auto-update widgets when state values change. Instead
of manually calling [`update()`](update.md) after every `state$set()`,
declare the relationship once and let rtui handle the rest.

## Usage

``` r
reactive(...)
```

## Arguments

- ...:

  Named arguments defining bindings. Each name is a state key, and each
  value is one of:

  character

  :   Widget id — sets the widget's `value` to the new state value. E.g.
      `count = "display"` updates the `"display"` widget's value
      whenever `state$set("count", x)` is called.

  formula

  :   A one-sided formula `~ expr` where `.x` is the new value, `.state`
      is the state object, and `.app` is the running app. E.g.
      `count = ~ update(.app, "display", value = paste("Count:", .x))`

  function

  :   A function `function(value, state, app)` for full control. Called
      whenever the state key changes.

  list

  :   A list of any of the above, to bind multiple widgets to the same
      state key.

## Value

A list of class `"rtui_reactive"` to pass to [`tui_app()`](tui_app.md)
or [`quick_app()`](quick_app.md).

## Examples

``` r
if (FALSE) { # \dontrun{
# Simple: state$count auto-updates the "display" widget's value
quick_app(
  layout = vstack(
    digits("0", id = "display"),
    button("+1", id = "inc"),
    id = "root"
  ),
  reactive = reactive(
    count = "display"
  ),
  on_click = list(
    inc = function(event, state) {
      state$set("count", state$get("count", 0L) + 1L)
      state
    }
  )
)

# Formula: transform the value before updating
reactive(
  count = ~ update(.app, "label", content = paste("Count is", .x))
)

# Function: full control
reactive(
  temperature = function(value, state, app) {
    update(app, "temp_display", value = paste0(value, "°C"))
    if (value > 100) notify(app, "Overheating!", severity = "warning")
  }
)

# Multiple widgets from one key
reactive(
  count = list("display", ~ update(.app, "label", content = paste("N:", .x)))
)
} # }
```
