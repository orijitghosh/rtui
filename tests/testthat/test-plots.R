# Tests for text_plot widget and plot_* functions

library(testthat)

# ---- text_plot() constructor ----

test_that("text_plot() creates a valid spec", {
  spec <- text_plot(id = "myplot")
  expect_s3_class(spec, "rtui_spec")
  expect_equal(spec$kind, "text_plot")
  expect_equal(spec$id, "myplot")
})

test_that("text_plot() works without id", {
  spec <- text_plot()
  expect_s3_class(spec, "rtui_spec")
  expect_null(spec$id)
})

test_that("text_plot() accepts classes", {
  spec <- text_plot(id = "p", classes = c("wide", "tall"))
  expect_equal(spec$classes, c("wide", "tall"))
})

# ---- plot_bar() validation ----

test_that("plot_bar() errors on non-RtuiApp", {
  expect_error(
    plot_bar("not_app", "p", c("A", "B"), c(1, 2)),
    "RtuiApp"
  )
})

# ---- plot_line() validation ----

test_that("plot_line() errors on non-RtuiApp", {
  expect_error(
    plot_line("not_app", "p", 1:3, 1:3),
    "RtuiApp"
  )
})

# ---- plot_scatter() validation ----

test_that("plot_scatter() errors on non-RtuiApp", {
  expect_error(
    plot_scatter("not_app", "p", 1:3, 1:3),
    "RtuiApp"
  )
})

# ---- plot_hist() validation ----

test_that("plot_hist() errors on non-RtuiApp", {
  expect_error(
    plot_hist("not_app", "p", rnorm(100)),
    "RtuiApp"
  )
})

# ---- Layout integration ----

test_that("text_plot() works inside vstack", {
  layout <- vstack(
    text_plot(id = "chart"),
    button("Redraw", id = "btn"),
    id = "root"
  )
  expect_s3_class(layout, "rtui_spec")
  expect_equal(layout$children[[1]]$kind, "text_plot")
})
