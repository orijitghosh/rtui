# Create a text widget

Create a text widget

## Usage

``` r
text(content, id = NULL, classes = NULL, tooltip = NULL)
```

## Arguments

- content:

  Character string to display.

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
# Simple text display
quick_app(
  layout = vstack(
    text("Hello world!", id = "greeting"),
    text("With tooltip", id = "tip", tooltip = "Hover me"),
    id = "root"
  )
)

# Update text from a handler
quick_app(
  layout = vstack(
    text("Click the button", id = "msg"),
    button("Go", id = "btn"),
    id = "root"
  ),
  on_click = list(
    btn = function(event, state) {
      update(state$app, "msg", content = "Button clicked!")
      state
    }
  )
)
} # }
```
