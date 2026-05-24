#' Create a key binding
#'
#' Key bindings map keyboard shortcuts to named actions. When the user presses
#' the bound key, an `"action"` event is dispatched with `event$value` set to
#' the action name. Bindings are shown in the [footer()] widget automatically.
#'
#' @param key Key combination (e.g. `"q"`, `"ctrl+s"`, `"f1"`).
#' @param action Action name (used as `event$value` in the action handler).
#' @param description Human-readable description shown in the footer.
#' @param priority If `TRUE`, the binding fires even when a widget has focus
#'   (e.g. when typing in an Input). Default `FALSE`. Set to `TRUE` for
#'   global shortcuts like quit or save.
#' @return A list of class `"rtui_binding"`.
#' @export
binding <- function(key, action, description = "", priority = FALSE) {
  if (!is.character(key) || length(key) != 1L || !nzchar(key)) {
    abort_spec("`key` must be a non-empty character string.")
  }
  if (!is.character(action) || length(action) != 1L || !nzchar(action)) {
    abort_spec("`action` must be a non-empty character string.")
  }
  if (!is.character(description) || length(description) != 1L) {
    abort_spec("`description` must be a single character string.")
  }
  if (!is.logical(priority) || length(priority) != 1L) {
    abort_spec("`priority` must be TRUE or FALSE.")
  }
  structure(
    list(key = key, action = action, description = description,
         priority = priority),
    class = "rtui_binding"
  )
}
