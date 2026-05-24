# Internal spec constructor and validators

new_spec <- function(kind, id = NULL, classes = NULL, props = list(),
                     children = NULL) {
  spec <- list(
    kind = kind,
    id = id,
    classes = classes,
    props = props,
    children = children
  )
  structure(spec, class = c("rtui_spec", "list"))
}

validate_id <- function(id, call = rlang::caller_env()) {
  if (is.null(id)) return(invisible(NULL))
  if (!is.character(id) || length(id) != 1L || is.na(id) || nchar(id) == 0L) {
    abort_spec("`id` must be a non-empty single character string.", call = call)
  }
  invisible(NULL)
}

validate_classes <- function(classes, call = rlang::caller_env()) {
  if (is.null(classes)) return(invisible(NULL))
  if (!is.character(classes)) {
    abort_spec("`classes` must be a character vector.", call = call)
  }
  invisible(NULL)
}

validate_children <- function(children, call = rlang::caller_env()) {
  for (i in seq_along(children)) {
    if (!inherits(children[[i]], "rtui_spec")) {
      abort_spec(
        paste0("Child ", i, " is not an rtui widget spec."),
        call = call
      )
    }
  }
  invisible(NULL)
}

compact <- function(x) {
  x[!vapply(x, is.null, logical(1))]
}

#' @export
print.rtui_spec <- function(x, ..., indent = 0L) {
  pad <- strrep("  ", indent)
  id_str <- if (!is.null(x$id)) paste0(" #", x$id) else ""
  cls_str <- if (!is.null(x$classes)) paste0(" .", paste(x$classes, collapse = ".")) else ""
  cat(pad, "<", x$kind, id_str, cls_str, ">\n", sep = "")
  if (length(x$props) > 0L) {
    for (nm in names(x$props)) {
      val <- x$props[[nm]]
      if (is.data.frame(val)) {
        cat(pad, "  ", nm, ": data.frame [", nrow(val), " x ", ncol(val), "]\n", sep = "")
      } else if (is.character(val) && length(val) > 3L) {
        cat(pad, "  ", nm, ": chr[", length(val), "]\n", sep = "")
      } else {
        cat(pad, "  ", nm, ": ", deparse(val, width.cutoff = 60L)[[1]], "\n", sep = "")
      }
    }
  }
  if (!is.null(x$children)) {
    for (child in x$children) {
      print.rtui_spec(child, indent = indent + 1L)
    }
  }
  invisible(x)
}
