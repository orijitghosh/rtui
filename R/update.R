#' Update a widget by id
#'
#' @param app An `RtuiApp` object.
#' @param id Widget id to update.
#' @param ... Named properties to set on the widget.
#' @return Invisible `app`.
#' @export
update <- function(app, id, ...) {
  if (!inherits(app, "RtuiApp")) {
    abort_spec("`app` must be an RtuiApp object.")
  }
  if (!is.character(id) || length(id) != 1L || nchar(id) == 0L) {
    abort_spec("`id` must be a non-empty string.")
  }
  patch <- list(...)
  if (length(patch) == 0L) return(invisible(app))

  if (!is.null(app$.__enclos_env__$private$.py_app)) {
    tryCatch(
      app$.__enclos_env__$private$.py_app$apply_update(id, patch),
      error = function(e) {
        abort_python(
          c("x" = paste0("Failed to update widget '", id, "'."),
            "i" = conditionMessage(e)),
          parent = e
        )
      }
    )
  }

  invisible(app)
}

#' Show a notification
#'
#' @param app An `RtuiApp` object.
#' @param message Notification message.
#' @param severity One of "info", "warning", "error".
#' @return Invisible `app`.
#' @export
notify <- function(app, message, severity = c("info", "warning", "error")) {
  if (!inherits(app, "RtuiApp")) {
    abort_spec("`app` must be an RtuiApp object.")
  }
  severity <- rlang::arg_match(severity)
  if (!is.character(message) || length(message) != 1L) {
    abort_spec("`message` must be a single character string.")
  }

  if (!is.null(app$.__enclos_env__$private$.py_app)) {
    tryCatch(
      app$.__enclos_env__$private$.py_app$send_notify(message, severity),
      error = function(e) {
        abort_python(
          c("x" = "Failed to send notification.",
            "i" = conditionMessage(e)),
          parent = e
        )
      }
    )
  }

  invisible(app)
}

#' Write a line to a log_view widget
#'
#' Appends text to a `log_view` (RichLog) widget. Supports Rich markup.
#'
#' @param app An `RtuiApp` object.
#' @param id Widget id of a `log_view`.
#' @param text Text to append.
#' @param markup Whether to interpret Rich markup (default FALSE).
#' @return Invisible `app`.
#' @export
log_write <- function(app, id, text, markup = FALSE) {
  if (!inherits(app, "RtuiApp")) {
    abort_spec("`app` must be an RtuiApp object.")
  }
  if (!is.character(text) || length(text) != 1L) {
    abort_spec("`text` must be a single character string.")
  }
  update(app, id, write = list(text = text, markup = markup))
}

#' Toggle dark mode
#'
#' Switches the app between dark and light mode at runtime.
#'
#' @param app An `RtuiApp` object.
#' @param dark Logical. If missing, toggles current mode.
#' @return Invisible `app`.
#' @export
dark_toggle <- function(app, dark) {
  if (!inherits(app, "RtuiApp")) {
    abort_spec("`app` must be an RtuiApp object.")
  }
  py_app <- app$.__enclos_env__$private$.py_app
  if (is.null(py_app)) abort_python("App is not running.")
  if (missing(dark)) {
    dark <- !py_app$dark
  }
  py_app$set_dark(dark)
  invisible(app)
}

#' Copy text to system clipboard
#'
#' Copies the given text to the system clipboard.
#'
#' @param app An `RtuiApp` object.
#' @param text Text to copy.
#' @return Invisible `app`.
#' @export
copy_to_clipboard <- function(app, text) {
  if (!inherits(app, "RtuiApp")) {
    abort_spec("`app` must be an RtuiApp object.")
  }
  if (!is.character(text) || length(text) != 1L) {
    abort_spec("`text` must be a single character string.")
  }
  py_app <- app$.__enclos_env__$private$.py_app
  if (is.null(py_app)) abort_python("App is not running.")
  py_app$copy_to_clipboard_native(text)
  invisible(app)
}
