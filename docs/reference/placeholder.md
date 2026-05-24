# Create a placeholder widget

A labelled placeholder area useful during development or for empty
states.

## Usage

``` r
placeholder(label = "Placeholder", id = NULL, classes = NULL)
```

## Arguments

- label:

  Placeholder label text.

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
  layout = hstack(
    placeholder("Sidebar"),
    placeholder("Main Content"),
    id = "root"
  )
)
} # }
```
