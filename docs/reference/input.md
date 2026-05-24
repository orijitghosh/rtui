# Create a text input widget

Create a text input widget

## Usage

``` r
input(
  placeholder = "",
  value = "",
  id = NULL,
  classes = NULL,
  tooltip = NULL,
  validators = NULL
)
```

## Arguments

- placeholder:

  Placeholder text.

- value:

  Initial value.

- id:

  Optional widget id.

- classes:

  Optional CSS classes (character vector).

- tooltip:

  Optional tooltip text.

- validators:

  Optional character vector of validators. Supported: `"number"`,
  `"integer"`, `"url"`, or `"regex:PATTERN"`.

## Value

An `rtui_spec` list.

## Examples

``` r
if (FALSE) { # \dontrun{
# Text input with change and submit handlers
quick_app(
  layout = vstack(
    input(placeholder = "Type your name...", id = "name"),
    input(placeholder = "Age", id = "age", validators = "integer"),
    static("", id = "output"),
    id = "root"
  ),
  on_submit = list(
    name = function(event, state) {
      update(state$app, "output",
             content = paste("Hello,", event$value))
      state
    }
  ),
  on_change = list(
    name = function(event, state) {
      # event$value contains the current text
      state
    }
  )
)
} # }
```
