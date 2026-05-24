# Create a static rich text widget

Displays text with support for [Rich
markup](https://rich.readthedocs.io/en/latest/markup.html) for colours,
bold, italic, etc.

## Usage

``` r
static(content, id = NULL, classes = NULL, tooltip = NULL)
```

## Arguments

- content:

  Character string to display (supports Rich markup).

- id:

  Optional widget id.

- classes:

  Optional CSS classes (character vector).

- tooltip:

  Optional tooltip text shown on hover.

## Value

An `rtui_spec` list.

## Examples

``` r
if (FALSE) { # \dontrun{
quick_app(
  layout = vstack(
    static("[bold red]Error:[/bold red] Something went wrong"),
    static("[green]Status:[/green] All systems operational"),
    static("[bold cyan]Score:[/bold cyan] 42", id = "score"),
    id = "root"
  ),
  # Update rich text from a handler
  on_click = list(
    btn = function(event, state) {
      update(state$app, "score",
             content = "[bold cyan]Score:[/bold cyan] 100")
      state
    }
  )
)
} # }
```
