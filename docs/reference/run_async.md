# Run a function asynchronously in a background process

Spawns an R background process via
[`callr::r_bg()`](https://callr.r-lib.org/reference/r_bg.html) and polls
for completion. When the task finishes, a `"task"` event is fired with:

- `event$timer_id`: the task `name`

- `event$value`: the return value of `fn` (or the error message on
  failure)

- `event$widget_id`: `"__async_ok"` on success, `"__async_error"` on
  failure

## Usage

``` r
run_async(app, fn, name, args = list(), poll = 0.5)
```

## Arguments

- app:

  An `RtuiApp` object (must be running).

- fn:

  A function to execute in the background. Must be self-contained — it
  cannot access the parent session's variables.

- name:

  A unique name for this task (character string).

- args:

  A named list of arguments passed to `fn`. Default
  [`list()`](https://rdrr.io/r/base/list.html).

- poll:

  Polling interval in seconds. Default `0.5`.

## Value

Invisible `app`.

## Details

Handle results with the `on_task` callback in
[`tui_app()`](https://orijitghosh.github.io/rtui/reference/tui_app.md).

The background process runs in a separate R session via the `callr`
package. The function `fn` must be self-contained: it cannot reference
objects from the calling environment. Pass any needed data through
`args`.

## Examples

``` r
if (FALSE) { # \dontrun{
quick_app(
  title = "Async Demo",
  layout = vstack(
    header(),
    static("Click to start a background task", id = "status"),
    button("Run Task", id = "run_btn"),
    footer()
  ),
  on_click = list(
    run_btn = function(event, state) {
      update(state$app, "status", content = "Working...")
      run_async(state$app, function() {
        Sys.sleep(3)
        42
      }, name = "my_task")
      state
    }
  ),
  on_task = function(event, state) {
    if (event$widget_id == "__async_ok") {
      update(state$app, "status",
             content = paste("Result:", event$value))
    } else {
      update(state$app, "status",
             content = paste("Error:", event$value))
    }
    state
  }
)
} # }
```
