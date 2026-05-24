#' @importFrom rlang abort
NULL

abort_spec <- function(message, ..., call = rlang::caller_env()) {
  rlang::abort(message, class = c("rtui_spec_error", "rtui_error"), ..., call = call)
}

abort_python <- function(message, ..., call = rlang::caller_env()) {
  rlang::abort(message, class = c("rtui_python_error", "rtui_error"), ..., call = call)
}

abort_no_tty <- function(message, ..., call = rlang::caller_env()) {
  rlang::abort(message, class = c("rtui_no_tty", "rtui_error"), ..., call = call)
}

abort_install <- function(message, ..., call = rlang::caller_env()) {
  rlang::abort(message, class = c("rtui_install_error", "rtui_error"), ..., call = call)
}

abort_callback <- function(message, ..., call = rlang::caller_env()) {
  rlang::abort(message, class = c("rtui_callback_error", "rtui_error"), ..., call = call)
}
