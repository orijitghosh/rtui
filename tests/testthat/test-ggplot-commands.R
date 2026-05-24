# Tests for ggplot bridge and command palette

library(testthat)

# ---- plot_ggplot ----

test_that("plot_ggplot() errors on non-ggplot object", {
  expect_error(plot_ggplot("x", "p", "not_a_ggplot"), "ggplot2")
})

test_that("plot_ggplot() errors on non-ggplot list", {
  expect_error(plot_ggplot("x", "p", list(a = 1)), "ggplot2")
})

# ---- command() ----

test_that("command() creates an rtui_command", {
  cmd <- command("Toggle Dark", "toggle_dark", help = "Switch theme")
  expect_s3_class(cmd, "rtui_command")
  expect_equal(cmd$name, "Toggle Dark")
  expect_equal(cmd$action, "toggle_dark")
  expect_equal(cmd$help, "Switch theme")
})

test_that("command() errors on empty name", {
  expect_error(command("", "action"), "non-empty")
})

test_that("command() errors on empty action", {
  expect_error(command("Name", ""), "non-empty")
})

test_that("command() default help is empty string", {
  cmd <- command("Test", "test_action")
  expect_equal(cmd$help, "")
})

# ---- register_commands ----

test_that("register_commands() errors on non-RtuiApp", {
  expect_error(register_commands("x", list()), "RtuiApp")
})

test_that("register_commands() errors on non-list", {
  expect_error(register_commands("x", "cmd"), "RtuiApp")
})
