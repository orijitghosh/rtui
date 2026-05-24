# Create a horizontal rule (divider) widget

Create a horizontal rule (divider) widget

## Usage

``` r
rule(label = NULL, id = NULL, classes = NULL)
```

## Arguments

- label:

  Optional label text centered on the rule.

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
    text("Section 1"),
    rule(),
    text("Section 2"),
    rule(label = "End"),
    id = "root"
  )
)
} # }
```
