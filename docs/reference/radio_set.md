# Create a radio set (group of radio buttons)

Create a radio set (group of radio buttons)

## Usage

``` r
radio_set(..., id = NULL, classes = NULL)
```

## Arguments

- ...:

  Radio button specs.

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
    static("Choose a size:"),
    radio_set(
      radio_button("Small"),
      radio_button("Medium", value = TRUE),
      radio_button("Large"),
      id = "size"
    ),
    static("", id = "chosen"),
    id = "root"
  ),
  on_change = list(
    size = function(event, state) {
      update(state$app, "chosen",
             content = paste("Selected:", event$value))
      state
    }
  )
)
} # }
```
