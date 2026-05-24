# Start a background worker

Workers are timers that poll an R function at a given interval. The
worker fires `"timer"` events at each tick; handle with
`app$handlers$timer`. This is a convenience wrapper around
[`set_interval()`](https://orijitghosh.github.io/rtui/reference/set_interval.md)
for polling patterns.

## Usage

``` r
set_worker(app, interval, name)
```

## Arguments

- app:

  An `RtuiApp` object.

- interval:

  Polling interval in seconds (numeric, \> 0).

- name:

  Worker name (used as `event$timer_id`).

## Value

Invisible `app`.
