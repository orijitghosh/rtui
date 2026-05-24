# Show a confirmation dialog

Pushes a modal screen with a message and Yes/No buttons. The result is
dispatched as a `"screen_result"` event with `event$value` set to `TRUE`
(confirmed) or `FALSE` (cancelled).

## Usage

``` r
confirm(app, message, title = "Confirm", yes_label = "Yes", no_label = "No")
```

## Arguments

- app:

  An `RtuiApp` object (or accessed via `state$app`).

- message:

  The question or message to display.

- title:

  Optional dialog title (default `"Confirm"`).

- yes_label:

  Label for the confirm button (default `"Yes"`).

- no_label:

  Label for the cancel button (default `"No"`).

## Value

Invisible `app`.

## Examples

``` r
if (FALSE) { # \dontrun{
quick_app(
  layout = vstack(
    button("Delete All", id = "del"),
    footer(),
    id = "root"
  ),
  on_click = list(
    del = function(event, state) {
      confirm(state$app, "Are you sure you want to delete everything?")
      state
    }
  ),
  on_screen_result = function(event, state) {
    if (isTRUE(event$value)) {
      notify(state$app, "Deleted!", severity = "warning")
    }
    state
  }
)
} # }
```
