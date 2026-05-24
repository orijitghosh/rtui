# Create an append-only log view widget

A scrolling log output, ideal for status messages, debug info, or
activity feeds. Use
[`log_write()`](https://orijitghosh.github.io/rtui/reference/log_write.md)
to append lines from handlers.

## Usage

``` r
log_view(id = NULL, classes = NULL, max_lines = 1000L)
```

## Arguments

- id:

  Optional widget id.

- classes:

  Optional CSS classes (character vector).

- max_lines:

  Maximum number of lines to retain.

## Value

An `rtui_spec` list.

## Examples

``` r
if (FALSE) { # \dontrun{
quick_app(
  layout = vstack(
    log_view(id = "logs", max_lines = 500),
    button("Add log", id = "add"),
    id = "root"
  ),
  on_click = list(
    add = function(event, state) {
      log_write(state$app, "logs", paste("Event at", Sys.time()))
      # Rich markup is supported
      log_write(state$app, "logs",
                "[green]OK[/green] Operation complete", markup = TRUE)
      state
    }
  )
)
} # }
```
