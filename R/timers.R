#' Create a repeating interval timer
#'
#' Fires a `"timer"` event at regular intervals. Handle with
#' `app$handlers$timer <- function(event, state) { ... }` where
#' `event$timer_id` is the timer name.
#'
#' @param app An `RtuiApp` object.
#' @param seconds Interval in seconds (numeric, > 0).
#' @param name Timer name (character string). Used as `event$timer_id`.
#' @return Invisible `app`.
#' @export
set_interval <- function(app, seconds, name) {
  if (!inherits(app, "RtuiApp")) {
    abort_spec("`app` must be an RtuiApp object.")
  }
  if (!is.numeric(seconds) || length(seconds) != 1L || seconds <= 0) {
    abort_spec("`seconds` must be a positive number.")
  }
  if (!is.character(name) || length(name) != 1L || !nzchar(name)) {
    abort_spec("`name` must be a non-empty character string.")
  }
  py_app <- app$.__enclos_env__$private$.py_app
  if (is.null(py_app)) {
    abort_python("Cannot set timer: app is not running.")
  }
  py_app$create_timer(name, seconds, TRUE)
  invisible(app)
}

#' Create a one-shot timer
#'
#' Fires a single `"timer"` event after a delay. Handle with
#' `app$handlers$timer <- function(event, state) { ... }`.
#'
#' @param app An `RtuiApp` object.
#' @param seconds Delay in seconds (numeric, > 0).
#' @param name Timer name (character string). Used as `event$timer_id`.
#' @return Invisible `app`.
#' @export
set_timer <- function(app, seconds, name) {
  if (!inherits(app, "RtuiApp")) {
    abort_spec("`app` must be an RtuiApp object.")
  }

  if (!is.numeric(seconds) || length(seconds) != 1L || seconds <= 0) {
    abort_spec("`seconds` must be a positive number.")
  }
  if (!is.character(name) || length(name) != 1L || !nzchar(name)) {
    abort_spec("`name` must be a non-empty character string.")
  }
  py_app <- app$.__enclos_env__$private$.py_app
  if (is.null(py_app)) {
    abort_python("Cannot set timer: app is not running.")
  }
  py_app$create_timer(name, seconds, FALSE)
  invisible(app)
}

#' Start a background worker
#'
#' Workers are timers that poll an R function at a given interval. The worker
#' fires `"timer"` events at each tick; handle with `app$handlers$timer`.
#' This is a convenience wrapper around [set_interval()] for polling patterns.
#'
#' @param app An `RtuiApp` object.
#' @param interval Polling interval in seconds (numeric, > 0).
#' @param name Worker name (used as `event$timer_id`).
#' @return Invisible `app`.
#' @export
set_worker <- function(app, interval, name) {
  set_interval(app, interval, name)
}

#' Cancel a running worker
#'
#' @param app An `RtuiApp` object.
#' @param name Worker name to cancel.
#' @return Invisible `app`.
#' @export
cancel_worker <- function(app, name) {
  clear_timer(app, name)
}

#' Cancel a running timer
#'
#' @param app An `RtuiApp` object.
#' @param name Timer name to cancel.
#' @return Invisible `app`.
#' @export
clear_timer <- function(app, name) {
  if (!inherits(app, "RtuiApp")) {
    abort_spec("`app` must be an RtuiApp object.")
  }
  if (!is.character(name) || length(name) != 1L || !nzchar(name)) {
    abort_spec("`name` must be a non-empty character string.")
  }
  py_app <- app$.__enclos_env__$private$.py_app
  if (is.null(py_app)) {
    abort_python("Cannot clear timer: app is not running.")
  }
  py_app$cancel_timer(name)
  invisible(app)
}
