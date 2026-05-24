#' Run an app with hot reload
#'
#' Watches a `.R` file for changes and automatically re-runs it when saved.
#' The file is sourced directly in the current R session. When the app
#' exits (user quits or it crashes), the file's modification time is
#' checked and the app re-sources if the file changed.
#'
#' **Workflow:** edit your `.R` file in an editor, save, then quit the
#' running app (e.g. press `q`) — it restarts automatically with your
#' changes. If the app crashes, it waits for the next file save before
#' restarting.
#'
#' Press `Ctrl+C` when the app is **not** running (i.e. between restarts)
#' to stop the watcher.
#'
#' @param file Path to an `.R` file that runs an rtui app.
#' @param poll Polling interval in seconds for file change detection
#'   (used when waiting for changes after app exit). Default `1`.
#' @return Called for its side effect (runs the app in a loop). Returns
#'   `NULL` invisibly when interrupted.
#'
#' @details
#' `dev_app()` is designed for rapid development iteration. It:
#'
#' 1. Sources and runs the given `.R` file
#' 2. When the app exits, checks if the file was modified
#' 3. If modified: re-sources immediately
#' 4. If not modified: polls until the file changes, then re-sources
#' 5. Continues until you press `Ctrl+C` between app runs
#'
#' Because the file is sourced directly (not via a subprocess), the app
#' gets full terminal control and all keyboard/mouse input works normally.
#'
#' @examples
#' \dontrun{
#' # In a terminal:
#' dev_app("my_app.R")
#'
#' # Edit my_app.R in your editor, save, quit the app — it restarts
#' }
#' @export
dev_app <- function(file, poll = 1) {
  if (!is.character(file) || length(file) != 1L || !nzchar(file)) {
    abort_spec("`file` must be a single file path.")
  }
  file <- normalizePath(file, mustWork = TRUE)
  if (!grepl("\\.R$", file, ignore.case = TRUE)) {
    abort_spec("`file` must be an .R file.")
  }
  if (!is.numeric(poll) || length(poll) != 1L || poll <= 0) {
    abort_spec("`poll` must be a positive number.")
  }

  cli::cli_alert_info("Watching {.file {file}} for changes")
  cli::cli_alert_info("Quit the app to check for changes; Ctrl+C between runs to stop")

  last_mtime <- file.mtime(file)

  tryCatch(
    repeat {
      cli::cli_alert_success("Starting app...")
      last_mtime <- file.mtime(file)

      tryCatch(
        source(file, local = new.env(parent = globalenv())),
        error = function(e) {
          cli::cli_alert_danger("App error: {conditionMessage(e)}")
        }
      )

      current_mtime <- file.mtime(file)
      if (!is.na(current_mtime) && current_mtime != last_mtime) {
        last_mtime <- current_mtime
        cli::cli_alert_info("File changed, restarting...")
        next
      }

      cli::cli_alert_info("App exited, waiting for changes...")
      repeat {
        Sys.sleep(poll)
        current_mtime <- file.mtime(file)
        if (!is.na(current_mtime) && current_mtime != last_mtime) {
          last_mtime <- current_mtime
          cli::cli_alert_info("File changed, restarting...")
          break
        }
      }
    },
    interrupt = function(e) {
      cli::cli_alert_info("Stopped watching.")
    }
  )

  invisible(NULL)
}
