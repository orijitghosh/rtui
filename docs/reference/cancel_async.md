# Cancel a running async task

Kills the background process and stops its polling timer.

## Usage

``` r
cancel_async(app, name)
```

## Arguments

- app:

  An `RtuiApp` object.

- name:

  Name of the task to cancel (as passed to
  [`run_async()`](https://orijitghosh.github.io/rtui/reference/run_async.md)).

## Value

Invisible `app`.
