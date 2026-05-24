# Create a box widget with optional border

Create a box widget with optional border

## Usage

``` r
box(
  child,
  border = c("none", "round", "heavy", "double"),
  title = NULL,
  id = NULL,
  classes = NULL
)
```

## Arguments

- child:

  A child widget spec.

- border:

  Border style: one of "none", "round", "heavy", "double".

- title:

  Optional box title.

- id:

  Optional widget id.

- classes:

  Optional CSS classes (character vector).

## Value

An `rtui_spec` list.
