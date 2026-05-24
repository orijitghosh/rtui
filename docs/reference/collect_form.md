# Collect form values from the running app

Queries all widget ids from a form and returns a named list of their
current values. This is called automatically when the form submit button
is clicked, but you can also call it manually from any handler.

## Usage

``` r
collect_form(app, field_ids)
```

## Arguments

- app:

  An `RtuiApp` object.

- field_ids:

  Character vector of widget ids to query.

## Value

A named list of current values.
