# Create a list view widget

Create a list view widget

## Usage

``` r
list_view(items, id = NULL, classes = NULL)
```

## Arguments

- items:

  Character vector of list items.

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
    list_view(items = c("Apple", "Banana", "Cherry"), id = "fruits"),
    static("Select a fruit", id = "msg"),
    id = "root"
  ),
  on_change = list(
    fruits = function(event, state) {
      update(state$app, "msg", content = paste("Selected:", event$value))
      state
    }
  )
)
} # }
```
