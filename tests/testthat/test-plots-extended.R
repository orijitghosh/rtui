# Tests for extended chart types and themes

library(testthat)

# ---- New chart R constructors (validation only) ----

test_that("plot_box() errors on non-RtuiApp", {
  expect_error(plot_box("x", "p", list(a = 1:5)), "RtuiApp")
})

test_that("plot_box() errors on non-list data", {
  expect_error(plot_box("x", "p", 1:5), "list of numeric")
})

test_that("plot_stacked_bar() errors on non-RtuiApp", {
  expect_error(plot_stacked_bar("x", "p", c("A"), list(Q1 = 1)), "RtuiApp")
})

test_that("plot_multiple_bar() errors on non-RtuiApp", {
  expect_error(plot_multiple_bar("x", "p", c("A"), list(Q1 = 1)), "RtuiApp")
})

test_that("plot_heatmap() errors on non-RtuiApp", {
  expect_error(plot_heatmap("x", "p", matrix(1:4, 2)), "RtuiApp")
})

test_that("plot_heatmap() errors on non-matrix", {
  expect_error(plot_heatmap("x", "p", "bad"), "RtuiApp")
})

test_that("plot_candlestick() errors on non-RtuiApp", {
  d <- list(open = 1, close = 2, high = 3, low = 0)
  expect_error(plot_candlestick("x", "p", "2024-01-01", d), "RtuiApp")
})

test_that("plot_error() errors on non-RtuiApp", {
  expect_error(plot_error("x", "p", 1:3, 1:3), "RtuiApp")
})

test_that("plot_event() errors on non-RtuiApp", {
  expect_error(plot_event("x", "p", c(1, 3, 5)), "RtuiApp")
})

# ---- Themes ----

test_that("tui_theme() returns a CSS string for each theme", {
  for (nm in list_themes()) {
    css <- tui_theme(nm)
    expect_type(css, "character")
    expect_true(nzchar(css), info = paste("Theme:", nm))
    expect_true(grepl("Screen", css), info = paste("Theme:", nm))
  }
})

test_that("list_themes() returns all 10 themes", {
  themes <- list_themes()
  expect_type(themes, "character")
  expect_true(length(themes) >= 10L)
  expect_true("dracula" %in% themes)
  expect_true("nord" %in% themes)
  expect_true("monokai" %in% themes)
  expect_true("solarized_dark" %in% themes)
  expect_true("solarized_light" %in% themes)
  expect_true("gruvbox" %in% themes)
  expect_true("catppuccin" %in% themes)
  expect_true("ocean" %in% themes)
  expect_true("forest" %in% themes)
  expect_true("sunset" %in% themes)
})

test_that("tui_theme() errors on invalid theme name", {
  expect_error(tui_theme("nonexistent"))
})

test_that("tui_theme() CSS contains Header and Footer rules", {
  css <- tui_theme("dracula")
  expect_true(grepl("Header", css))
  expect_true(grepl("Footer", css))
  expect_true(grepl("Button", css))
})

# ---- .get_py_plot_app helper ----

test_that(".get_py_plot_app errors on non-RtuiApp", {
  expect_error(rtui:::.get_py_plot_app("bad"), "RtuiApp")
})
