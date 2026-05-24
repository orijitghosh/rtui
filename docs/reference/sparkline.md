# Create a sparkline widget

A compact inline chart for showing trends at a glance.

## Usage

``` r
sparkline(data, id = NULL, classes = NULL)
```

## Arguments

- data:

  Numeric vector of values.

- id:

  Optional widget id.

- classes:

  Optional CSS classes (character vector).

## Value

An `rtui_spec` list.

## Examples

``` r
if (FALSE) { # \dontrun{
# Static sparkline
quick_app(
  layout = vstack(
    static("CPU Usage"),
    sparkline(c(10, 45, 30, 80, 55, 90, 40, 60), id = "cpu"),
    id = "root"
  )
)

# Live-updating sparkline with a timer
quick_app(
  layout = vstack(sparkline(c(0), id = "live"), id = "root"),
  on_mount = function(event, state) {
    state$set("vals", numeric(0))
    set_interval(state$app, 0.5, "tick")
    state
  },
  on_timer = function(event, state) {
    vals <- c(state$get("vals"), runif(1, 0, 100))
    if (length(vals) > 40) vals <- tail(vals, 40)
    state$set("vals", vals)
    update(state$app, "live", data = vals)
    state
  }
)
} # }
```
