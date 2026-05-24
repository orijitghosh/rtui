#' Wrap a function as a key-event handler
#' @param handler A function taking `(event, state)`.
#' @return The handler with class `"rtui_key_handler"`.
#' @export
event_key <- function(handler) {
  if (!is.function(handler)) {
    abort_spec("`handler` must be a function.")
  }
  structure(handler, class = c("rtui_key_handler", "rtui_handler", "function"))
}

#' Wrap a function as a change-event handler
#' @param handler A function taking `(event, state)`.
#' @return The handler with class `"rtui_change_handler"`.
#' @export
event_change <- function(handler) {
  if (!is.function(handler)) {
    abort_spec("`handler` must be a function.")
  }
  structure(handler, class = c("rtui_change_handler", "rtui_handler", "function"))
}

#' Wrap a function as a click-event handler
#' @param handler A function taking `(event, state)`.
#' @return The handler with class `"rtui_click_handler"`.
#' @export
event_click <- function(handler) {
  if (!is.function(handler)) {
    abort_spec("`handler` must be a function.")
  }
  structure(handler, class = c("rtui_click_handler", "rtui_handler", "function"))
}

#' Signal app termination from a callback
#' @param result Optional result to return from `app$run()`.
#' @return A sentinel object of class `"rtui_quit"`.
#' @export
quit <- function(result = NULL) {
  structure(list(result = result), class = "rtui_quit")
}
