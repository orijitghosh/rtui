# Create a multi-line text area widget

Create a multi-line text area widget

## Usage

``` r
text_area(
  value = "",
  language = NULL,
  show_line_numbers = FALSE,
  id = NULL,
  classes = NULL
)
```

## Arguments

- value:

  Initial text content.

- language:

  Optional language for syntax highlighting (e.g. `"r"`, `"python"`,
  `"json"`, `"markdown"`, `"sql"`).

- show_line_numbers:

  Show line numbers.

- id:

  Optional widget id.

- classes:

  Optional CSS classes (character vector).

## Value

An `rtui_spec` list.

## Examples

``` r
if (FALSE) { # \dontrun{
# Code editor with syntax highlighting
quick_app(
  layout = vstack(
    text_area(value = "x <- 1:10\nmean(x)\nsd(x)",
              language = "r",
              show_line_numbers = TRUE,
              id = "editor"),
    button("Run", id = "run"),
    id = "root"
  ),
  on_change = list(
    editor = function(event, state) {
      state$set("code", event$value)
      state
    }
  )
)

# Markdown editor with live preview
quick_app(
  layout = hstack(
    text_area(value = "# Title\n\nSome **bold** text.",
              id = "editor", show_line_numbers = TRUE),
    markdown("", id = "preview"),
    id = "root"
  ),
  on_change = list(
    editor = function(event, state) {
      update(state$app, "preview", content = event$value)
      state
    }
  )
)
} # }
```
