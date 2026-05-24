#' Create a vertical stack layout
#' @param ... Child widget specs.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#' @export
vstack <- function(..., id = NULL, classes = NULL) {
  children <- list(...)
  validate_children(children)
  validate_id(id)
  validate_classes(classes)
  new_spec("vstack", id = id, classes = classes, children = children)
}

#' Create a horizontal stack layout
#' @param ... Child widget specs.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#' @export
hstack <- function(..., id = NULL, classes = NULL) {
  children <- list(...)
  validate_children(children)
  validate_id(id)
  validate_classes(classes)
  new_spec("hstack", id = id, classes = classes, children = children)
}

#' Create a grid layout
#' @param ... Child widget specs.
#' @param rows Number of rows (integer or NULL).
#' @param cols Number of columns (integer or NULL).
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#' @export
grid <- function(..., rows = NULL, cols = NULL, id = NULL, classes = NULL) {
  children <- list(...)
  validate_children(children)
  validate_id(id)
  validate_classes(classes)
  if (!is.null(rows)) {
    if (!is.numeric(rows) || length(rows) != 1L || rows < 1L) {
      abort_spec("`rows` must be a positive integer.")
    }
    rows <- as.integer(rows)
  }
  if (!is.null(cols)) {
    if (!is.numeric(cols) || length(cols) != 1L || cols < 1L) {
      abort_spec("`cols` must be a positive integer.")
    }
    cols <- as.integer(cols)
  }
  new_spec("grid", id = id, classes = classes,
           props = compact(list(rows = rows, cols = cols)),
           children = children)
}

#' Create a plain block container
#' @param ... Child widget specs.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#' @export
container <- function(..., id = NULL, classes = NULL) {
  children <- list(...)
  validate_children(children)
  validate_id(id)
  validate_classes(classes)
  new_spec("container", id = id, classes = classes, children = children)
}

#' Create a scrollable container
#' @param ... Child widget specs.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#' @export
scroll <- function(..., id = NULL, classes = NULL) {
  children <- list(...)
  validate_children(children)
  validate_id(id)
  validate_classes(classes)
  new_spec("scroll", id = id, classes = classes, children = children)
}

#' Create a center-aligned container
#' @param ... Child widget specs.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#' @export
center <- function(..., id = NULL, classes = NULL) {
  children <- list(...)
  validate_children(children)
  validate_id(id)
  validate_classes(classes)
  new_spec("center", id = id, classes = classes, children = children)
}

#' Create a middle-aligned container (vertical centering)
#' @param ... Child widget specs.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#' @export
middle <- function(..., id = NULL, classes = NULL) {
  children <- list(...)
  validate_children(children)
  validate_id(id)
  validate_classes(classes)
  new_spec("middle", id = id, classes = classes, children = children)
}
