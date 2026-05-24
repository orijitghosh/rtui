# Create a key binding

Key bindings map keyboard shortcuts to named actions. When the user
presses the bound key, an `"action"` event is dispatched with
`event$value` set to the action name. Bindings are shown in the
[`footer()`](footer.md) widget automatically.

## Usage

``` r
binding(key, action, description = "", priority = FALSE)
```

## Arguments

- key:

  Key combination (e.g. `"q"`, `"ctrl+s"`, `"f1"`).

- action:

  Action name (used as `event$value` in the action handler).

- description:

  Human-readable description shown in the footer.

- priority:

  If `TRUE`, the binding fires even when a widget has focus (e.g. when
  typing in an Input). Default `FALSE`. Set to `TRUE` for global
  shortcuts like quit or save.

## Value

A list of class `"rtui_binding"`.
