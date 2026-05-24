#' Run a function asynchronously in a background process
#'
#' Spawns an R background process via `callr::r_bg()` and polls for
#' completion.
#' When the task finishes, a `"task"` event is fired with:
#' - `event$timer_id`: the task `name`
#' - `event$value`: the return value of `fn` (or the error message on failure)
#' - `event$widget_id`: `"__async_ok"` on success, `"__async_error"` on failure
#'
#' Handle results with the `on_task` callback in [tui_app()].
#'
#' @param app An `RtuiApp` object (must be running).
#' @param fn A function to execute in the background. Must be
#'   self-contained — it cannot access the parent session's variables.
#' @param name A unique name for this task (character string).
#' @param args A named list of arguments passed to `fn`. Default `list()`.
#' @param poll Polling interval in seconds. Default `0.5`.
#' @return Invisible `app`.
#'
#' @details
#' The background process runs in a separate R session via the `callr`
#' package. The function `fn` must be self-contained: it cannot reference
#' objects from the calling environment. Pass any needed data through `args`.
#'
#' @examples
#' \dontrun{
#' quick_app(
#'   title = "Async Demo",
#'   layout = vstack(
#'     header(),
#'     static("Click to start a background task", id = "status"),
#'     button("Run Task", id = "run_btn"),
#'     footer()
#'   ),
#'   on_click = list(
#'     run_btn = function(event, state) {
#'       update(state$app, "status", content = "Working...")
#'       run_async(state$app, function() {
#'         Sys.sleep(3)
#'         42
#'       }, name = "my_task")
#'       state
#'     }
#'   ),
#'   on_task = function(event, state) {
#'     if (event$widget_id == "__async_ok") {
#'       update(state$app, "status",
#'              content = paste("Result:", event$value))
#'     } else {
#'       update(state$app, "status",
#'              content = paste("Error:", event$value))
#'     }
#'     state
#'   }
#' )
#' }
#' @export
run_async <- function(app, fn, name, args = list(), poll = 0.5) {
  if (!inherits(app, "RtuiApp")) {
    abort_spec("`app` must be an RtuiApp object.")
  }
  if (!is.function(fn)) {
    abort_spec("`fn` must be a function.")
  }
  if (!is.character(name) || length(name) != 1L || !nzchar(name)) {
    abort_spec("`name` must be a non-empty character string.")
  }
  if (!is.list(args)) {
    abort_spec("`args` must be a list.")
  }
  if (!is.numeric(poll) || length(poll) != 1L || poll <= 0) {
    abort_spec("`poll` must be a positive number.")
  }
  if (!requireNamespace("callr", quietly = TRUE)) {
    abort_python(c(
      "x" = "The {.pkg callr} package is required for `run_async()`.",
      "i" = "Install it with: install.packages(\"callr\")"
    ))
  }

  py_app <- app$.__enclos_env__$private$.py_app
  if (is.null(py_app)) {
    abort_python("Cannot run async task: app is not running.")
  }

  proc <- callr::r_bg(fn, args = args, supervise = TRUE)

  tasks <- app$.__enclos_env__$private$.async_tasks
  if (is.null(tasks)) tasks <- list()
  tasks[[name]] <- proc
  app$.__enclos_env__$private$.async_tasks <- tasks

  set_interval(app, poll, paste0("__async_poll_", name))
  invisible(app)
}


#' Cancel a running async task
#'
#' Kills the background process and stops its polling timer.
#'
#' @param app An `RtuiApp` object.
#' @param name Name of the task to cancel (as passed to [run_async()]).
#' @return Invisible `app`.
#' @export
cancel_async <- function(app, name) {
  if (!inherits(app, "RtuiApp")) {
    abort_spec("`app` must be an RtuiApp object.")
  }
  if (!is.character(name) || length(name) != 1L || !nzchar(name)) {
    abort_spec("`name` must be a non-empty character string.")
  }

  tasks <- app$.__enclos_env__$private$.async_tasks
  proc <- tasks[[name]]
  if (!is.null(proc) && proc$is_alive()) {
    proc$kill()
  }
  tasks[[name]] <- NULL
  app$.__enclos_env__$private$.async_tasks <- tasks

  tryCatch(
    clear_timer(app, paste0("__async_poll_", name)),
    error = function(e) NULL
  )
  invisible(app)
}
