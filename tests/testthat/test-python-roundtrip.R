skip_if_no_python <- function() {
  testthat::skip_if_not(
    reticulate::py_available(initialize = FALSE),
    "Python not available"
  )
  testthat::skip_if_not(
    reticulate::virtualenv_exists("r-rtui"),
    "r-rtui virtualenv not set up — run rtui::install_python_deps()"
  )
}

test_that("Python shim can be imported", {
  skip_if_no_python()
  shim <- load_shim()
  expect_true(!is.null(shim))
})
