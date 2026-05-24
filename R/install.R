#' Install Python dependencies for rtui
#'
#' Creates a dedicated virtualenv and installs pinned Textual requirements.
#'
#' @param envname Name of the virtualenv (default: "r-rtui").
#' @param python Path to a Python interpreter. If `NULL`, uses reticulate's
#'   default discovery. On Windows, the Microsoft Store Python is not supported;
#'   provide a path to a python.org install (e.g., Python 3.12).
#' @return Invisible `TRUE` on success.
#' @export
install_python_deps <- function(envname = "r-rtui", python = NULL) {
  req_file <- system.file("python", "requirements.txt", package = "rtui")
  if (!nzchar(req_file)) {
    abort_install("Cannot find requirements.txt in rtui package installation.")
  }

  packages <- trimws(readLines(req_file))
  packages <- packages[nzchar(packages) & !startsWith(packages, "#")]

  tryCatch(
    {
      args <- list(envname = envname)
      if (!is.null(python)) args$python <- python
      do.call(reticulate::virtualenv_create, args)

      py_ver <- reticulate::py_eval(
        "'.'.join(map(str, __import__('sys').version_info[:2]))"
      )
      if (numeric_version(py_ver) < "3.10") {
        abort_install(paste0(
          "Python >= 3.10 is required for Textual, but found Python ", py_ver, "."
        ))
      }

      reticulate::virtualenv_install(
        envname = envname,
        packages = packages,
        ignore_installed = FALSE
      )
      cli::cli_alert_success(
        "Python dependencies installed in virtualenv {.val {envname}}."
      )
      cli::cli_alert_info(
        "Restart R, then {.code library(rtui)} will use this environment."
      )
      invisible(TRUE)
    },
    error = function(e) {
      abort_install(
        c("x" = "Failed to install Python dependencies.",
          "i" = "Ensure Python >= 3.10 is available (not Microsoft Store Python on Windows).",
          "i" = conditionMessage(e)),
        parent = e
      )
    }
  )
}
