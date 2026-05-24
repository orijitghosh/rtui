# Create a progress bar widget

Create a progress bar widget

## Usage

``` r
progress_bar(
  total = 100,
  progress = 0,
  show_eta = TRUE,
  show_percentage = TRUE,
  id = NULL,
  classes = NULL
)
```

## Arguments

- total:

  Total value (numeric).

- progress:

  Current progress value (numeric).

- show_eta:

  Show estimated time of arrival.

- show_percentage:

  Show percentage.

- id:

  Optional widget id.

- classes:

  Optional CSS classes (character vector).

## Value

An `rtui_spec` list.

## Examples

``` r
if (FALSE) { # \dontrun{
# Progress bar that advances on each click
quick_app(
  layout = vstack(
    progress_bar(total = 100, progress = 0, id = "pb"),
    button("Advance +10", id = "go"),
    id = "root"
  ),
  on_click = list(
    go = function(event, state) {
      p <- min(state$get("p", 0) + 10, 100)
      state$set("p", p)
      update(state$app, "pb", progress = p)
      if (p >= 100) notify(state$app, "Done!", severity = "info")
      state
    }
  )
)

# Auto-advancing progress bar with a timer
quick_app(
  layout = vstack(
    progress_bar(total = 50, id = "pb", show_eta = TRUE),
    id = "root"
  ),
  on_mount = function(event, state) {
    state$set("p", 0)
    set_interval(state$app, 0.2, "tick")
    state
  },
  on_timer = function(event, state) {
    p <- state$get("p", 0) + 1
    state$set("p", p)
    update(state$app, "pb", progress = p)
    if (p >= 50) clear_timer(state$app, "tick")
    state
  }
)
} # }
```
