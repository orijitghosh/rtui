# Create a checkbox widget

Create a checkbox widget

## Usage

``` r
checkbox(label, value = FALSE, id = NULL, classes = NULL, tooltip = NULL)
```

## Arguments

- label:

  Checkbox label text.

- value:

  Initial checked state (logical).

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
    checkbox("Enable notifications", value = TRUE, id = "notif"),
    checkbox("Dark mode", value = FALSE, id = "dark"),
    static("", id = "status"),
    id = "root"
  ),
  on_change = list(
    notif = function(event, state) {
      update(state$app, "status",
             content = paste("Notifications:", event$value))
      state
    },
    dark = function(event, state) {
      dark_toggle(state$app, event$value)
      state
    }
  )
)
} # }
```
