# Create a form with named inputs and a submit button

Builds a vertical layout with labelled form fields and a submit button.
When the user presses the submit button, all current field values are
collected into a named list and passed to the `on_submit` callback.

## Usage

``` r
tui_form(..., submit_label = "Submit", id = NULL, classes = NULL)
```

## Arguments

- ...:

  Named form field specs. Each should be an `rtui_spec` for an input
  widget (e.g.
  [`input()`](https://orijitghosh.github.io/rtui/reference/input.md),
  [`select()`](https://orijitghosh.github.io/rtui/reference/select.md),
  [`checkbox()`](https://orijitghosh.github.io/rtui/reference/checkbox.md),
  [`switch_input()`](https://orijitghosh.github.io/rtui/reference/switch_input.md)).
  The name is used as both the widget id and the display label.

- submit_label:

  Label for the submit button (default `"Submit"`).

- id:

  Optional id for the enclosing container.

- classes:

  Optional CSS classes.

## Value

An `rtui_spec` list representing the form layout.

## Details

The form auto-generates widget ids from the field names (spaces replaced
with underscores, lowercased). Use `on_click` with id `"__form_submit"`
to handle submission.

Field values are also collected and stored in state under
`".form_values"` each time a field changes. When submit is clicked the
`on_click` handler receives `event$value$form_data` with all current
values.

## Examples

``` r
if (FALSE) { # \dontrun{
quick_app(
  layout = vstack(
    header(),
    tui_form(
      Name = input(placeholder = "Your name"),
      Email = input(placeholder = "you@example.com", validators = "url"),
      Department = select(c("Engineering", "Marketing", "Sales")),
      Active = checkbox("Currently active", value = TRUE),
      id = "myform"
    ),
    footer(),
    id = "root"
  ),
  on_click = list(
    `__form_submit` = function(event, state) {
      vals <- state$get(".form_values", list())
      notify(state$app, paste("Name:", vals$name))
      state
    }
  )
)
} # }
```
