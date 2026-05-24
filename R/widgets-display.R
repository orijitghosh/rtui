#' Create a text widget
#' @param content Character string to display.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @param tooltip Optional tooltip text shown on hover.
#' @return An `rtui_spec` list.
#'
#' @examples
#' \dontrun{
#' # Simple text display
#' quick_app(
#'   layout = vstack(
#'     text("Hello world!", id = "greeting"),
#'     text("With tooltip", id = "tip", tooltip = "Hover me"),
#'     id = "root"
#'   )
#' )
#'
#' # Update text from a handler
#' quick_app(
#'   layout = vstack(
#'     text("Click the button", id = "msg"),
#'     button("Go", id = "btn"),
#'     id = "root"
#'   ),
#'   on_click = list(
#'     btn = function(event, state) {
#'       update(state$app, "msg", content = "Button clicked!")
#'       state
#'     }
#'   )
#' )
#' }
#'
#' @export
text <- function(content, id = NULL, classes = NULL, tooltip = NULL) {
  if (!is.character(content) || length(content) != 1L) {
    abort_spec("`content` must be a single character string.")
  }
  validate_id(id)
  validate_classes(classes)
  new_spec("text", id = id, classes = classes,
           props = compact(list(content = content, tooltip = tooltip)))
}

#' Create a box widget with optional border
#' @param child A child widget spec.
#' @param border Border style: one of "none", "round", "heavy", "double".
#' @param title Optional box title.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#'
#' @examples
#' \dontrun{
#' # Box with a border and title
#' quick_app(
#'   layout = vstack(
#'     box(text("Important notice"), border = "round", title = "Alert"),
#'     box(text("Heavy border"), border = "heavy"),
#'     box(text("Double border"), border = "double", title = "Info"),
#'     id = "root"
#'   )
#' )
#' }
#'
#' @export
box <- function(child, border = c("none", "round", "heavy", "double"),
                title = NULL, id = NULL, classes = NULL) {
  border <- rlang::arg_match(border)
  if (!inherits(child, "rtui_spec")) {
    abort_spec("`child` must be an rtui widget spec.")
  }
  if (!is.null(title)) {
    if (!is.character(title) || length(title) != 1L) {
      abort_spec("`title` must be a single character string.")
    }
  }
  validate_id(id)
  validate_classes(classes)
  new_spec("box", id = id, classes = classes,
           props = compact(list(border = border, title = title)),
           children = list(child))
}

#' Create a static rich text widget
#'
#' Displays text with support for [Rich markup](https://rich.readthedocs.io/en/latest/markup.html)
#' for colours, bold, italic, etc.
#'
#' @param content Character string to display (supports Rich markup).
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @param tooltip Optional tooltip text shown on hover.
#' @return An `rtui_spec` list.
#'
#' @examples
#' \dontrun{
#' quick_app(
#'   layout = vstack(
#'     static("[bold red]Error:[/bold red] Something went wrong"),
#'     static("[green]Status:[/green] All systems operational"),
#'     static("[bold cyan]Score:[/bold cyan] 42", id = "score"),
#'     id = "root"
#'   ),
#'   # Update rich text from a handler
#'   on_click = list(
#'     btn = function(event, state) {
#'       update(state$app, "score",
#'              content = "[bold cyan]Score:[/bold cyan] 100")
#'       state
#'     }
#'   )
#' )
#' }
#'
#' @export
static <- function(content, id = NULL, classes = NULL, tooltip = NULL) {
  if (!is.character(content) || length(content) != 1L) {
    abort_spec("`content` must be a single character string.")
  }
  validate_id(id)
  validate_classes(classes)
  new_spec("static", id = id, classes = classes,
           props = compact(list(content = content, tooltip = tooltip)))
}

#' Create an append-only log view widget
#'
#' A scrolling log output, ideal for status messages, debug info, or activity
#' feeds. Use [log_write()] to append lines from handlers.
#'
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @param max_lines Maximum number of lines to retain.
#' @return An `rtui_spec` list.
#'
#' @examples
#' \dontrun{
#' quick_app(
#'   layout = vstack(
#'     log_view(id = "logs", max_lines = 500),
#'     button("Add log", id = "add"),
#'     id = "root"
#'   ),
#'   on_click = list(
#'     add = function(event, state) {
#'       log_write(state$app, "logs", paste("Event at", Sys.time()))
#'       # Rich markup is supported
#'       log_write(state$app, "logs",
#'                 "[green]OK[/green] Operation complete", markup = TRUE)
#'       state
#'     }
#'   )
#' )
#' }
#'
#' @export
log_view <- function(id = NULL, classes = NULL, max_lines = 1000L) {
  validate_id(id)
  validate_classes(classes)
  if (!is.numeric(max_lines) || length(max_lines) != 1L || max_lines < 1L) {
    abort_spec("`max_lines` must be a positive integer.")
  }
  new_spec("log_view", id = id, classes = classes,
           props = list(max_lines = as.integer(max_lines)))
}

#' Create a markdown display widget
#'
#' Renders Markdown content including headings, lists, code blocks, bold,
#' italic, and links.
#'
#' @param content Markdown text to render.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#'
#' @examples
#' \dontrun{
#' quick_app(
#'   layout = vstack(
#'     markdown("# Hello\n\nThis is **bold** and *italic*.\n\n- Item 1\n- Item 2",
#'              id = "docs"),
#'     button("Update", id = "btn"),
#'     id = "root"
#'   ),
#'   on_click = list(
#'     btn = function(event, state) {
#'       update(state$app, "docs",
#'              content = "# Updated\n\nNew markdown content with `code`.")
#'       state
#'     }
#'   )
#' )
#' }
#'
#' @export
markdown <- function(content, id = NULL, classes = NULL) {
  if (!is.character(content) || length(content) != 1L) {
    abort_spec("`content` must be a single character string.")
  }
  validate_id(id)
  validate_classes(classes)
  new_spec("markdown", id = id, classes = classes,
           props = list(content = content))
}

#' Create a progress bar widget
#' @param total Total value (numeric).
#' @param progress Current progress value (numeric).
#' @param show_eta Show estimated time of arrival.
#' @param show_percentage Show percentage.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#'
#' @examples
#' \dontrun{
#' # Progress bar that advances on each click
#' quick_app(
#'   layout = vstack(
#'     progress_bar(total = 100, progress = 0, id = "pb"),
#'     button("Advance +10", id = "go"),
#'     id = "root"
#'   ),
#'   on_click = list(
#'     go = function(event, state) {
#'       p <- min(state$get("p", 0) + 10, 100)
#'       state$set("p", p)
#'       update(state$app, "pb", progress = p)
#'       if (p >= 100) notify(state$app, "Done!", severity = "info")
#'       state
#'     }
#'   )
#' )
#'
#' # Auto-advancing progress bar with a timer
#' quick_app(
#'   layout = vstack(
#'     progress_bar(total = 50, id = "pb", show_eta = TRUE),
#'     id = "root"
#'   ),
#'   on_mount = function(event, state) {
#'     state$set("p", 0)
#'     set_interval(state$app, 0.2, "tick")
#'     state
#'   },
#'   on_timer = function(event, state) {
#'     p <- state$get("p", 0) + 1
#'     state$set("p", p)
#'     update(state$app, "pb", progress = p)
#'     if (p >= 50) clear_timer(state$app, "tick")
#'     state
#'   }
#' )
#' }
#'
#' @export
progress_bar <- function(total = 100, progress = 0, show_eta = TRUE,
                         show_percentage = TRUE, id = NULL, classes = NULL) {
  if (!is.numeric(total) || length(total) != 1L || total <= 0) {
    abort_spec("`total` must be a positive number.")
  }
  if (!is.numeric(progress) || length(progress) != 1L) {
    abort_spec("`progress` must be a single number.")
  }
  validate_id(id)
  validate_classes(classes)
  new_spec("progress_bar", id = id, classes = classes,
           props = list(total = total, progress = progress,
                        show_eta = show_eta, show_percentage = show_percentage))
}

#' Create a sparkline widget
#'
#' A compact inline chart for showing trends at a glance.
#'
#' @param data Numeric vector of values.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#'
#' @examples
#' \dontrun{
#' # Static sparkline
#' quick_app(
#'   layout = vstack(
#'     static("CPU Usage"),
#'     sparkline(c(10, 45, 30, 80, 55, 90, 40, 60), id = "cpu"),
#'     id = "root"
#'   )
#' )
#'
#' # Live-updating sparkline with a timer
#' quick_app(
#'   layout = vstack(sparkline(c(0), id = "live"), id = "root"),
#'   on_mount = function(event, state) {
#'     state$set("vals", numeric(0))
#'     set_interval(state$app, 0.5, "tick")
#'     state
#'   },
#'   on_timer = function(event, state) {
#'     vals <- c(state$get("vals"), runif(1, 0, 100))
#'     if (length(vals) > 40) vals <- tail(vals, 40)
#'     state$set("vals", vals)
#'     update(state$app, "live", data = vals)
#'     state
#'   }
#' )
#' }
#'
#' @export
sparkline <- function(data, id = NULL, classes = NULL) {
  if (!is.numeric(data)) {
    abort_spec("`data` must be a numeric vector.")
  }
  validate_id(id)
  validate_classes(classes)
  new_spec("sparkline", id = id, classes = classes,
           props = list(data = data))
}

#' Create a horizontal rule (divider) widget
#' @param label Optional label text centered on the rule.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#'
#' @examples
#' \dontrun{
#' quick_app(
#'   layout = vstack(
#'     text("Section 1"),
#'     rule(),
#'     text("Section 2"),
#'     rule(label = "End"),
#'     id = "root"
#'   )
#' )
#' }
#'
#' @export
rule <- function(label = NULL, id = NULL, classes = NULL) {
  if (!is.null(label) && (!is.character(label) || length(label) != 1L)) {
    abort_spec("`label` must be a single character string or NULL.")
  }
  validate_id(id)
  validate_classes(classes)
  new_spec("rule", id = id, classes = classes,
           props = compact(list(label = label)))
}

#' Create a loading indicator widget
#'
#' An animated spinner shown while content is loading.
#'
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#'
#' @examples
#' \dontrun{
#' # Show loading spinner, then hide after data loads
#' quick_app(
#'   layout = vstack(
#'     loading(id = "spinner"),
#'     text("", id = "result"),
#'     id = "root"
#'   ),
#'   on_mount = function(event, state) {
#'     set_timer(state$app, 2, "loaded")
#'     state
#'   },
#'   on_timer = function(event, state) {
#'     update(state$app, "spinner", display = FALSE)
#'     update(state$app, "result", content = "Data loaded!")
#'     state
#'   }
#' )
#' }
#'
#' @export
loading <- function(id = NULL, classes = NULL) {
  validate_id(id)
  validate_classes(classes)
  new_spec("loading", id = id, classes = classes)
}

#' Create a large digits display widget
#'
#' Shows text in a large, blocky font -- ideal for counters, clocks, and
#' dashboards. Supports digits 0-9, colons, spaces, and periods.
#'
#' @param value Text to display in large digits (numbers/colon/space).
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#'
#' @examples
#' \dontrun{
#' # Counter with large digits
#' quick_app(
#'   layout = vstack(
#'     header(),
#'     center(middle(vstack(
#'       digits("0", id = "count"),
#'       hstack(
#'         button("-1", id = "dec"),
#'         button("+1", id = "inc")
#'       )
#'     ))),
#'     footer()
#'   ),
#'   on_click = list(
#'     inc = function(event, state) {
#'       n <- state$get("n", 0L) + 1L
#'       state$set("n", n)
#'       update(state$app, "count", value = as.character(n))
#'       state
#'     },
#'     dec = function(event, state) {
#'       n <- state$get("n", 0L) - 1L
#'       state$set("n", n)
#'       update(state$app, "count", value = as.character(n))
#'       state
#'     }
#'   )
#' )
#'
#' # Clock display
#' quick_app(
#'   layout = center(middle(digits("00:00:00", id = "clock"))),
#'   on_mount = function(event, state) {
#'     set_interval(state$app, 1, "tick")
#'     state
#'   },
#'   on_timer = function(event, state) {
#'     update(state$app, "clock", value = format(Sys.time(), "%H:%M:%S"))
#'     state
#'   }
#' )
#' }
#'
#' @export
digits <- function(value = "", id = NULL, classes = NULL) {
  if (!is.character(value) || length(value) != 1L) {
    abort_spec("`value` must be a single character string.")
  }
  validate_id(id)
  validate_classes(classes)
  new_spec("digits", id = id, classes = classes,
           props = list(value = value))
}

#' Create a placeholder widget
#'
#' A labelled placeholder area useful during development or for empty states.
#'
#' @param label Placeholder label text.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#'
#' @examples
#' \dontrun{
#' quick_app(
#'   layout = hstack(
#'     placeholder("Sidebar"),
#'     placeholder("Main Content"),
#'     id = "root"
#'   )
#' )
#' }
#'
#' @export
placeholder <- function(label = "Placeholder", id = NULL, classes = NULL) {
  if (!is.character(label) || length(label) != 1L) {
    abort_spec("`label` must be a single character string.")
  }
  validate_id(id)
  validate_classes(classes)
  new_spec("placeholder", id = id, classes = classes,
           props = list(label = label))
}

#' Create a pretty table widget (rich-formatted)
#'
#' Renders a data.frame as a formatted static table (non-interactive).
#' For an interactive table with sorting and selection, see [data_table()].
#'
#' @param df A data.frame to display.
#' @param title Optional table title.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#'
#' @examples
#' \dontrun{
#' quick_app(
#'   layout = vstack(
#'     pretty_table(head(mtcars, 5), title = "Motor Trend Cars", id = "tbl"),
#'     pretty_table(head(iris, 3), title = "Iris Dataset"),
#'     id = "root"
#'   )
#' )
#' }
#'
#' @export
pretty_table <- function(df, title = NULL, id = NULL, classes = NULL) {
  if (!is.data.frame(df)) {
    abort_spec("`df` must be a data.frame.")
  }
  if (!is.null(title) && (!is.character(title) || length(title) != 1L)) {
    abort_spec("`title` must be a single character string or NULL.")
  }
  validate_id(id)
  validate_classes(classes)
  new_spec("pretty_table", id = id, classes = classes,
           props = compact(list(df = df, title = title)))
}
