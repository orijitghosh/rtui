#' Create a text widget
#' @param content Character string to display.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @param tooltip Optional tooltip text shown on hover.
#' @return An `rtui_spec` list.
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
#' @param content Character string to display (supports Rich markup).
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @param tooltip Optional tooltip text shown on hover.
#' @return An `rtui_spec` list.
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
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @param max_lines Maximum number of lines to retain.
#' @return An `rtui_spec` list.
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
#' @param content Markdown text to render.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
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
#' @param data Numeric vector of values.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
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
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#' @export
loading <- function(id = NULL, classes = NULL) {
  validate_id(id)
  validate_classes(classes)
  new_spec("loading", id = id, classes = classes)
}

#' Create a large digits display widget
#' @param value Text to display in large digits (numbers/colon/space).
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
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
#' @param label Placeholder label text.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
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
#' @param df A data.frame to display.
#' @param title Optional table title.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
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
