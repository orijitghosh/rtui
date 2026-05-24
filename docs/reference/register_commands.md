# Register commands for the command palette

Registers a list of
[`command()`](https://orijitghosh.github.io/rtui/reference/command.md)
objects that appear in the Textual command palette (Ctrl+P). When a
command is selected, it dispatches an `"action"` event to `on_action`.

## Usage

``` r
register_commands(app, commands)
```

## Arguments

- app:

  An `RtuiApp` object.

- commands:

  A list of
  [`command()`](https://orijitghosh.github.io/rtui/reference/command.md)
  objects.

## Value

Invisible `app`.
