test_that("check_terminal aborts for TERM=dumb", {
  withr::local_envvar(TERM = "dumb", RSTUDIO = "", POSITRON = "")
  expect_error(check_terminal(), class = "rtui_no_tty")
})

test_that("check_terminal aborts for RStudio", {
  withr::local_envvar(TERM = "xterm-256color", RSTUDIO = "1", POSITRON = "")
  expect_error(check_terminal(), class = "rtui_no_tty")
})

test_that("check_terminal aborts for Positron", {
  withr::local_envvar(TERM = "xterm-256color", RSTUDIO = "", POSITRON = "1")
  expect_error(check_terminal(), class = "rtui_no_tty")
})
