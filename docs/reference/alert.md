# Show an alert dialog

Pushes a modal screen with a message and an OK button. Dismisses with
`event$value = TRUE` in the `"screen_result"` handler.

## Usage

``` r
alert(app, message, title = "Alert", ok_label = "OK")
```

## Arguments

- app:

  An `RtuiApp` object.

- message:

  The message to display.

- title:

  Optional dialog title (default `"Alert"`).

- ok_label:

  Label for the OK button (default `"OK"`).

## Value

Invisible `app`.

## Examples

``` r
if (FALSE) { # \dontrun{
quick_app(
  layout = vstack(
    button("Show Info", id = "info"),
    footer(),
    id = "root"
  ),
  on_click = list(
    info = function(event, state) {
      alert(state$app, "Operation completed successfully!")
      state
    }
  )
)
} # }
```
