# Define a command palette entry

Creates a command that will appear in the Textual command palette
(opened with Ctrl+P). When selected, it dispatches an `"action"` event
with the given action name.

## Usage

``` r
command(name, action, help = "")
```

## Arguments

- name:

  Display name shown in the palette.

- action:

  Action name dispatched as `event$value` in `on_action`.

- help:

  Optional help text shown below the command name.

## Value

A command spec list.
