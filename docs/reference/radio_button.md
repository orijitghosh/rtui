# Create a radio button widget (use inside radio_set)

Create a radio button widget (use inside radio_set)

## Usage

``` r
radio_button(label, value = FALSE, id = NULL, classes = NULL)
```

## Arguments

- label:

  Radio button label text.

- value:

  Whether this button is selected.

- id:

  Optional widget id.

- classes:

  Optional CSS classes (character vector).

## Value

An `rtui_spec` list.

## Examples

``` r
if (FALSE) { # \dontrun{
# See radio_set() for a complete example
radio_button("Option A")
radio_button("Option B", value = TRUE)  # pre-selected
} # }
```
