#' Check if the current terminal supports TUI rendering
#' @return `TRUE` invisibly if supported; aborts otherwise.
#' @keywords internal
check_terminal <- function(call = rlang::caller_env()) {
  if (!isatty(stdin())) {
    abort_no_tty(
      c("x" = "rtui requires an interactive terminal (stdin is not a tty).",
        "i" = "Run R from a terminal emulator, not a pipe or script."),
      call = call
    )
  }

  if (identical(Sys.getenv("TERM"), "dumb")) {
    abort_no_tty(
      c("x" = "rtui requires a capable terminal (TERM is 'dumb').",
        "i" = "Use a modern terminal: Windows Terminal, iTerm2, Alacritty, or GNOME Terminal."),
      call = call
    )
  }

  if (identical(Sys.getenv("RSTUDIO"), "1")) {
    abort_no_tty(
      c("x" = "rtui cannot run inside RStudio's console.",
        "i" = "Launch R from an external terminal instead."),
      call = call
    )
  }

  if (nzchar(Sys.getenv("POSITRON"))) {
    abort_no_tty(
      c("x" = "rtui cannot run inside Positron's integrated console.",
        "i" = "Launch R from an external terminal instead."),
      call = call
    )
  }

  invisible(TRUE)
}
