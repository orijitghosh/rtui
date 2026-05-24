.onLoad <- function(libname, pkgname) {
  if (reticulate::virtualenv_exists("r-rtui")) {
    tryCatch(
      reticulate::use_virtualenv("r-rtui", required = FALSE),
      error = function(e) {
        packageStartupMessage(
          "Note: rtui virtualenv 'r-rtui' exists but could not be activated: ",
          conditionMessage(e)
        )
      }
    )
  }
}
