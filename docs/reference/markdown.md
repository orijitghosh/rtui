# Create a markdown display widget

Renders Markdown content including headings, lists, code blocks, bold,
italic, and links.

## Usage

``` r
markdown(content, id = NULL, classes = NULL)
```

## Arguments

- content:

  Markdown text to render.

- id:

  Optional widget id.

- classes:

  Optional CSS classes (character vector).

## Value

An `rtui_spec` list.

## Examples

``` r
if (FALSE) { # \dontrun{
quick_app(
  layout = vstack(
    markdown("# Hello\n\nThis is **bold** and *italic*.\n\n- Item 1\n- Item 2",
             id = "docs"),
    button("Update", id = "btn"),
    id = "root"
  ),
  on_click = list(
    btn = function(event, state) {
      update(state$app, "docs",
             content = "# Updated\n\nNew markdown content with `code`.")
      state
    }
  )
)
} # }
```
