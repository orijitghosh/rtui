#' Define a command palette entry
#'
#' Creates a command that will appear in the Textual command palette
#' (opened with Ctrl+P). When selected, it dispatches an `"action"` event
#' with the given action name.
#'
#' @param name Display name shown in the palette.
#' @param action Action name dispatched as `event$value` in `on_action`.
#' @param help Optional help text shown below the command name.
#' @return A command spec list.
#' @export
command <- function(name, action, help = "") {
  if (!is.character(name) || length(name) != 1L || !nzchar(name)) {
    abort_spec("`name` must be a non-empty character string.")
  }
  if (!is.character(action) || length(action) != 1L || !nzchar(action)) {
    abort_spec("`action` must be a non-empty character string.")
  }
  if (!is.character(help) || length(help) != 1L) {
    abort_spec("`help` must be a single character string.")
  }
  structure(
    list(name = name, action = action, help = help),
    class = "rtui_command"
  )
}

#' Register commands for the command palette
#'
#' Registers a list of [command()] objects that appear in the Textual
#' command palette (Ctrl+P). When a command is selected, it dispatches
#' an `"action"` event to `on_action`.
#'
#' @param app An `RtuiApp` object.
#' @param commands A list of [command()] objects.
#' @return Invisible `app`.
#' @export
register_commands <- function(app, commands) {
  if (!inherits(app, "RtuiApp")) {
    abort_spec("`app` must be an RtuiApp object.")
  }
  if (!is.list(commands)) {
    abort_spec("`commands` must be a list of command() objects.")
  }
  for (cmd in commands) {
    if (!inherits(cmd, "rtui_command")) {
      abort_spec("Each command must be created with command().")
    }
  }
  py_app <- app$.__enclos_env__$private$.py_app
  if (is.null(py_app)) abort_python("App is not running.")
  cmd_list <- lapply(commands, function(c) {
    list(name = c$name, action = c$action, help = c$help)
  })
  py_app$register_commands(cmd_list)
  invisible(app)
}
