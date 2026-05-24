# Create a loading indicator widget

An animated spinner shown while content is loading.

## Usage

``` r
loading(id = NULL, classes = NULL)
```

## Arguments

- id:

  Optional widget id.

- classes:

  Optional CSS classes (character vector).

## Value

An `rtui_spec` list.

## Examples

``` r
if (FALSE) { # \dontrun{
# Show loading spinner, then hide after data loads
quick_app(
  layout = vstack(
    loading(id = "spinner"),
    text("", id = "result"),
    id = "root"
  ),
  on_mount = function(event, state) {
    set_timer(state$app, 2, "loaded")
    state
  },
  on_timer = function(event, state) {
    update(state$app, "spinner", display = FALSE)
    update(state$app, "result", content = "Data loaded!")
    state
  }
)
} # }
```
