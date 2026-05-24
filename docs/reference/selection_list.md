# Create a selection list (multi-select)

Like
[`option_list()`](https://orijitghosh.github.io/rtui/reference/option_list.md)
but allows the user to toggle multiple items on/off.

## Usage

``` r
selection_list(items, id = NULL, classes = NULL)
```

## Arguments

- items:

  Character vector of items.

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
    static("Select permissions:"),
    selection_list(items = c("Read", "Write", "Execute"),
                   id = "perms"),
    static("", id = "chosen"),
    id = "root"
  ),
  on_change = list(
    perms = function(event, state) {
      update(state$app, "chosen",
             content = paste("Selected:", toString(event$value)))
      state
    }
  )
)
} # }
```
