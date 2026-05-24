#' Create a tabbed pane container
#' @param ... Tab pane specs created with `tab_pane()`.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#' @export
tabs <- function(..., id = NULL, classes = NULL) {
  children <- list(...)
  validate_children(children)
  validate_id(id)
  validate_classes(classes)
  new_spec("tabs", id = id, classes = classes, children = children)
}

#' Create a single tab pane
#' @param title Tab title shown in the tab bar.
#' @param ... Child widget specs for this tab's content.
#' @param id Optional widget id (used as tab identifier).
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#' @export
tab_pane <- function(title, ..., id = NULL, classes = NULL) {
  if (!is.character(title) || length(title) != 1L) {
    abort_spec("`title` must be a single character string.")
  }
  children <- list(...)
  validate_children(children)
  validate_id(id)
  validate_classes(classes)
  new_spec("tab_pane", id = id, classes = classes,
           props = list(title = title), children = children)
}

#' Create a header widget
#' @param show_clock Show a clock in the header.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#' @export
header <- function(show_clock = FALSE, id = NULL, classes = NULL) {
  if (!is.logical(show_clock) || length(show_clock) != 1L) {
    abort_spec("`show_clock` must be TRUE or FALSE.")
  }
  validate_id(id)
  validate_classes(classes)
  new_spec("header", id = id, classes = classes,
           props = list(show_clock = show_clock))
}

#' Create a footer widget
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#' @export
footer <- function(id = NULL, classes = NULL) {
  validate_id(id)
  validate_classes(classes)
  new_spec("footer", id = id, classes = classes)
}

#' Create a collapsible section
#' @param title Section title.
#' @param ... Child widget specs.
#' @param collapsed Initial collapsed state.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#' @export
collapsible <- function(title, ..., collapsed = TRUE, id = NULL,
                        classes = NULL) {
  if (!is.character(title) || length(title) != 1L) {
    abort_spec("`title` must be a single character string.")
  }
  if (!is.logical(collapsed) || length(collapsed) != 1L) {
    abort_spec("`collapsed` must be TRUE or FALSE.")
  }
  children <- list(...)
  validate_children(children)
  validate_id(id)
  validate_classes(classes)
  new_spec("collapsible", id = id, classes = classes,
           props = list(title = title, collapsed = collapsed),
           children = children)
}

#' Create a content switcher (shows one child at a time)
#' @param ... Child widget specs (each must have an id).
#' @param initial Id of the initially visible child.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#' @export
content_switcher <- function(..., initial = NULL, id = NULL, classes = NULL) {
  children <- list(...)
  validate_children(children)
  if (!is.null(initial) && (!is.character(initial) || length(initial) != 1L)) {
    abort_spec("`initial` must be a single character string or NULL.")
  }
  validate_id(id)
  validate_classes(classes)
  new_spec("content_switcher", id = id, classes = classes,
           props = compact(list(initial = initial)),
           children = children)
}

#' Create a directory tree widget
#' @param path Path to the directory to display.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#' @export
directory_tree <- function(path = ".", id = NULL, classes = NULL) {
  if (!is.character(path) || length(path) != 1L) {
    abort_spec("`path` must be a single character string.")
  }
  validate_id(id)
  validate_classes(classes)
  new_spec("directory_tree", id = id, classes = classes,
           props = list(path = path))
}

#' Create a tree widget
#' @param label Root label for the tree.
#' @param data A nested list representing the tree structure. Each element
#'   can be a character string (leaf) or a named list (branch).
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#' @export
tree <- function(label, data = list(), id = NULL, classes = NULL) {
  if (!is.character(label) || length(label) != 1L) {
    abort_spec("`label` must be a single character string.")
  }
  if (!is.list(data)) {
    abort_spec("`data` must be a list.")
  }
  validate_id(id)
  validate_classes(classes)
  new_spec("tree", id = id, classes = classes,
           props = list(label = label, data = data))
}
