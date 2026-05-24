# Tests for advanced features: log_write, dark_toggle, copy_to_clipboard

library(testthat)

# ---- log_write ----

test_that("log_write() errors on non-RtuiApp", {
  expect_error(log_write("x", "log", "hello"), "RtuiApp")
})

test_that("log_write() errors on non-string text", {
  expect_error(log_write("x", "log", 123), "RtuiApp")
})

# ---- dark_toggle ----

test_that("dark_toggle() errors on non-RtuiApp", {
  expect_error(dark_toggle("x"), "RtuiApp")
})

# ---- copy_to_clipboard ----

test_that("copy_to_clipboard() errors on non-RtuiApp", {
  expect_error(copy_to_clipboard("x", "hello"), "RtuiApp")
})

test_that("copy_to_clipboard() errors on non-string text", {
  expect_error(copy_to_clipboard("x", 123), "RtuiApp")
})
