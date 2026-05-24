# Create a large digits display widget

Shows text in a large, blocky font – ideal for counters, clocks, and
dashboards. Supports digits 0-9, colons, spaces, and periods.

## Usage

``` r
digits(value = "", id = NULL, classes = NULL)
```

## Arguments

- value:

  Text to display in large digits (numbers/colon/space).

- id:

  Optional widget id.

- classes:

  Optional CSS classes (character vector).

## Value

An `rtui_spec` list.

## Examples

``` r
if (FALSE) { # \dontrun{
# Counter with large digits
quick_app(
  layout = vstack(
    header(),
    center(middle(vstack(
      digits("0", id = "count"),
      hstack(
        button("-1", id = "dec"),
        button("+1", id = "inc")
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
    }
  )
)

# Clock display
quick_app(
  layout = center(middle(digits("00:00:00", id = "clock"))),
  on_mount = function(event, state) {
    set_interval(state$app, 1, "tick")
    state
  },
  on_timer = function(event, state) {
    update(state$app, "clock", value = format(Sys.time(), "%H:%M:%S"))
    state
  }
)
} # }
```
