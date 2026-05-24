#' Create a screen spec
#'
#' Screens are used with [push_screen()] to create multi-page apps and modal
#' dialogs. A screen has its own layout and optional CSS.
#'
#' @param layout A widget spec defining the screen layout.
#' @param css Optional Textual CSS string for this screen.
#' @return An object of class `"rtui_screen_spec"`.
#' @export
tui_screen <- function(layout, css = NULL) {
  if (!inherits(layout, "rtui_spec")) {
    abort_spec("`layout` must be an rtui widget spec.")
  }
  if (!is.null(css) && (!is.character(css) || length(css) != 1L)) {
    abort_spec("`css` must be a single character string or NULL.")
  }
  structure(
    list(layout = layout, css = css),
    class = "rtui_screen_spec"
  )
}

#' Push a screen onto the screen stack
#'
#' The current screen is preserved and a new screen is shown on top.
#' Use [pop_screen()] from a callback to dismiss it.
#'
#' @param app An `RtuiApp` object (must be running).
#' @param screen A screen spec created with [tui_screen()].
#' @return Invisible `app`.
#' @export
push_screen <- function(app, screen) {
  if (!inherits(app, "RtuiApp")) {
    abort_spec("`app` must be an RtuiApp object.")
  }
  if (!inherits(screen, "rtui_screen_spec")) {
    abort_spec("`screen` must be a screen spec created with `tui_screen()`.")
  }
  py_app <- app$.__enclos_env__$private$.py_app
  if (is.null(py_app)) {
    abort_python("Cannot push screen: app is not running.")
  }
  py_app$push_screen_from_spec(screen)
  invisible(app)
}

#' Pop the current screen from the stack
#'
#' Dismisses the top screen, returning to the screen below. Optionally
#' passes a result value back which is dispatched as a `"screen_result"`
#' event (handle via `app$handlers$screen_result`).
#'
#' @param app An `RtuiApp` object (must be running).
#' @param result Optional result value to pass back.
#' @return Invisible `app`.
#' @export
pop_screen <- function(app, result = NULL) {
  if (!inherits(app, "RtuiApp")) {
    abort_spec("`app` must be an RtuiApp object.")
  }
  py_app <- app$.__enclos_env__$private$.py_app
  if (is.null(py_app)) {
    abort_python("Cannot pop screen: app is not running.")
  }
  py_app$pop_screen_with_result(result)
  invisible(app)
}
