test_that("tui_state() creates empty state", {
  s <- tui_state()
  expect_s3_class(s, "RtuiState")
  expect_length(s$as_list(), 0)
})

test_that("tui_state() accepts initial values", {
  s <- tui_state(list(count = 0L, name = "test"))
  expect_equal(s$get("count"), 0L)
  expect_equal(s$get("name"), "test")
})

test_that("tui_state() rejects non-list initial", {
  expect_error(tui_state("bad"), class = "rtui_spec_error")
  expect_error(tui_state(42), class = "rtui_spec_error")
})

test_that("state$get returns default for missing keys", {
  s <- tui_state()
  expect_null(s$get("missing"))
  expect_equal(s$get("missing", 42L), 42L)
})

test_that("state$set mutates state", {
  s <- tui_state()
  s$set("x", 10)
  expect_equal(s$get("x"), 10)
})

test_that("state$as_list returns all values", {
  s <- tui_state(list(a = 1, b = 2))
  l <- s$as_list()
  expect_equal(l, list(a = 1, b = 2))
})

test_that("state$data active binding works", {
  s <- tui_state(list(a = 1))
  expect_equal(s$data, list(a = 1))
  s$data <- list(b = 2)
  expect_equal(s$get("b"), 2)
  expect_null(s$get("a"))
})

test_that("state-determinism: identical operations yield identical state", {
  s1 <- tui_state(list(x = 0))
  s1$set("x", 1)
  s1$set("y", "hello")

  s2 <- tui_state(list(x = 0))
  s2$set("x", 1)
  s2$set("y", "hello")

  expect_equal(s1$as_list(), s2$as_list())
})
