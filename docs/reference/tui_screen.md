# Create a screen spec

Screens are used with [`push_screen()`](push_screen.md) to create
multi-page apps and modal dialogs. A screen has its own layout and
optional CSS.

## Usage

``` r
tui_screen(layout, css = NULL)
```

## Arguments

- layout:

  A widget spec defining the screen layout.

- css:

  Optional Textual CSS string for this screen.

## Value

An object of class `"rtui_screen_spec"`.
