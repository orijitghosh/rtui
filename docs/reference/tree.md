# Create a tree widget

Create a tree widget

## Usage

``` r
tree(label, data = list(), id = NULL, classes = NULL)
```

## Arguments

- label:

  Root label for the tree.

- data:

  A nested list representing the tree structure. Each element can be a
  character string (leaf) or a named list (branch).

- id:

  Optional widget id.

- classes:

  Optional CSS classes (character vector).

## Value

An `rtui_spec` list.
