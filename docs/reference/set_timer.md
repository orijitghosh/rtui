# Create a one-shot timer

Fires a single `"timer"` event after a delay. Handle with
`app$handlers$timer <- function(event, state) { ... }`.

## Usage

``` r
set_timer(app, seconds, name)
```

## Arguments

- app:

  An `RtuiApp` object.

- seconds:

  Delay in seconds (numeric, \> 0).

- name:

  Timer name (character string). Used as `event$timer_id`.

## Value

Invisible `app`.
