# Create a button widget

Create a button widget

## Usage

``` r
button(label, id = NULL, classes = NULL, tooltip = NULL)
```

## Arguments

- label:

  Button label text.

- id:

  Optional widget id.

- classes:

  Optional CSS classes (character vector).

- tooltip:

  Optional tooltip text shown on hover.

## Value

An `rtui_spec` list.

## Examples

``` r
if (FALSE) { # \dontrun{
quick_app(
  layout = vstack(
    button("Click Me", id = "btn", tooltip = "Press to greet"),
    button("Disabled", id = "off"),
    static("", id = "msg"),
    id = "root"
  ),
  on_mount = function(event, state) {
    update(state$app, "off", disabled = TRUE)
    state
  },
  on_click = list(
    btn = function(event, state) {
      update(state$app, "msg", content = "Hello!")
      update(state$app, "btn", label = "Clicked!")
      state
    }
  )
)
} # }
```
