# Create an option list widget

A scrollable list of selectable options. Fires `on_change` events when
the user highlights or selects an item.

## Usage

``` r
option_list(items, id = NULL, classes = NULL)
```

## Arguments

- items:

  Character vector of option items.

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
    option_list(items = c("Apple", "Banana", "Cherry", "Date"),
                id = "fruits"),
    static("Pick a fruit", id = "msg"),
    button("Update list", id = "update_btn"),
    id = "root"
  ),
  on_change = list(
    fruits = function(event, state) {
      update(state$app, "msg", content = paste("Picked:", event$value))
      state
    }
  ),
  on_click = list(
    update_btn = function(event, state) {
      # Replace items dynamically
      update(state$app, "fruits", items = c("Fig", "Grape", "Kiwi"))
      state
    }
  )
)
} # }
```
