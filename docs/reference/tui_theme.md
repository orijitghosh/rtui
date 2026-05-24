# Get a built-in theme CSS string

Returns a Textual CSS string that styles the app with a named colour
theme. Pass the result to the `css` parameter of
[`tui_app()`](https://orijitghosh.github.io/rtui/reference/tui_app.md)
or
[`quick_app()`](https://orijitghosh.github.io/rtui/reference/quick_app.md),
or append it to your own CSS.

## Usage

``` r
tui_theme(
  name = c("dracula", "nord", "monokai", "solarized_dark", "solarized_light", "gruvbox",
    "catppuccin", "ocean", "forest", "sunset")
)
```

## Arguments

- name:

  Theme name. One of: `"dracula"`, `"nord"`, `"monokai"`,
  `"solarized_dark"`, `"solarized_light"`, `"gruvbox"`, `"catppuccin"`,
  `"ocean"`, `"forest"`, `"sunset"`.

## Value

A single CSS string.

## Examples

``` r
if (FALSE) { # \dontrun{
quick_app(
  layout = vstack(header(), text("Hello!"), footer(), id = "root"),
  css = tui_theme("dracula")
)
} # }
```
