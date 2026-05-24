# Push a screen onto the screen stack

The current screen is preserved and a new screen is shown on top. Use
[`pop_screen()`](pop_screen.md) from a callback to dismiss it.

## Usage

``` r
push_screen(app, screen)
```

## Arguments

- app:

  An `RtuiApp` object (must be running).

- screen:

  A screen spec created with [`tui_screen()`](tui_screen.md).

## Value

Invisible `app`.
