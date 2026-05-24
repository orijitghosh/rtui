# Create a masked input widget

Template uses special characters: `A` (letter), `9` (digit), `!` (force
upper), `>` (force upper following), `<` (force lower following). Other
characters are literal separators. Example: `"999-999-9999"` for phone,
`"AA99 AA"` for UK postcode.

## Usage

``` r
masked_input(
  template,
  value = NULL,
  placeholder = "",
  id = NULL,
  classes = NULL
)
```

## Arguments

- template:

  Template string defining the input mask.

- value:

  Initial value (or NULL).

- placeholder:

  Placeholder text.

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
    static("Phone:"),
    masked_input(template = "999-999-9999", id = "phone"),
    static("Postcode:"),
    masked_input(template = "AA99 9AA", id = "postcode"),
    static("Date:"),
    masked_input(template = "99/99/9999", id = "date"),
    id = "root"
  )
)
} # }
```
