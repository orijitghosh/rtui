# Pop the current screen from the stack

Dismisses the top screen, returning to the screen below. Optionally
passes a result value back which is dispatched as a `"screen_result"`
event (handle via `app$handlers$screen_result`).

## Usage

``` r
pop_screen(app, result = NULL)
```

## Arguments

- app:

  An `RtuiApp` object (must be running).

- result:

  Optional result value to pass back.

## Value

Invisible `app`.
