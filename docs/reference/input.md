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
