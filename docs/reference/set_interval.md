# Create a repeating interval timer

Fires a `"timer"` event at regular intervals. Handle with
`app$handlers$timer <- function(event, state) { ... }` where
`event$timer_id` is the timer name.

## Usage

``` r
set_interval(app, seconds, name)
```

## Arguments

- app:

  An `RtuiApp` object.

- seconds:

  Interval in seconds (numeric, \> 0).

- name:

  Timer name (character string). Used as `event$timer_id`.

## Value

Invisible `app`.
