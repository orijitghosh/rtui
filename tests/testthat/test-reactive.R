# Tests for reactive state bindings

library(testthat)

# ---- reactive() constructor ----

test_that("reactive() returns an rtui_reactive object", {
  r <- reactive(count = "display")
  expect_s3_class(r, "rtui_reactive")
})

test_that("reactive() errors on empty input", {
  expect_error(reactive(), "At least one binding")
})

test_that("reactive() errors on unnamed bindings", {
  expect_error(reactive("display"), "must be named")
})

test_that("reactive() accepts widget id (string)", {
  r <- reactive(count = "display")
  expect_type(r$count, "list")
  expect_length(r$count, 1L)
  expect_type(r$count[[1]], "closure")
})

test_that("reactive() accepts function", {
  fn <- function(value, state, app) NULL
  r <- reactive(count = fn)
  expect_identical(r$count[[1]], fn)
})

test_that("reactive() accepts formula", {
  r <- reactive(count = ~ paste("Count:", .x))
  expect_type(r$count[[1]], "closure")
})

test_that("reactive() accepts list for multiple bindings to same key", {
  r <- reactive(
    count = list("display", function(v, s, a) NULL)
  )
  expect_length(r$count, 2L)
})

test_that("reactive() errors on unsupported binding type", {
  expect_error(reactive(count = 42), "must be a widget id")
})

# ---- State reactivity ----

test_that("state$set() fires reactive binding when value changes", {
  fired <- 0L
  observed_value <- NULL

  state <- tui_state()
  # Fake app
  fake_app <- structure(list(), class = "RtuiApp")
  state$set(".app", fake_app)

  # Install a binding manually for testing
  bindings <- list(count = list(function(value, state, app) {
    fired <<- fired + 1L
    observed_value <<- value
  }))
  state$.__enclos_env__$private$.reactive <- bindings

  state$set("count", 5L)
  expect_equal(fired, 1L)
  expect_equal(observed_value, 5L)

  state$set("count", 10L)
  expect_equal(fired, 2L)
  expect_equal(observed_value, 10L)
})

test_that("state$set() does NOT fire when value is unchanged (identical)", {
  fired <- 0L
  state <- tui_state()
  fake_app <- structure(list(), class = "RtuiApp")
  state$set(".app", fake_app)
  state$.__enclos_env__$private$.reactive <- list(
    count = list(function(v, s, a) fired <<- fired + 1L)
  )

  state$set("count", 5L)
  expect_equal(fired, 1L)
  state$set("count", 5L)  # same value, no fire
  expect_equal(fired, 1L)
})

test_that("state$set() does NOT fire when no app is registered", {
  fired <- 0L
  state <- tui_state()
  # No .app set
  state$.__enclos_env__$private$.reactive <- list(
    count = list(function(v, s, a) fired <<- fired + 1L)
  )

  state$set("count", 5L)
  expect_equal(fired, 0L)
})

test_that("state$set() does NOT fire for keys with no binding", {
  fired <- 0L
  state <- tui_state()
  fake_app <- structure(list(), class = "RtuiApp")
  state$set(".app", fake_app)
  state$.__enclos_env__$private$.reactive <- list(
    count = list(function(v, s, a) fired <<- fired + 1L)
  )

  state$set("other", 99L)
  expect_equal(fired, 0L)
})

test_that("multiple bindings on same key all fire", {
  fired1 <- 0L
  fired2 <- 0L
  state <- tui_state()
  fake_app <- structure(list(), class = "RtuiApp")
  state$set(".app", fake_app)
  state$.__enclos_env__$private$.reactive <- list(
    count = list(
      function(v, s, a) fired1 <<- fired1 + 1L,
      function(v, s, a) fired2 <<- fired2 + 1L
    )
  )

  state$set("count", 5L)
  expect_equal(fired1, 1L)
  expect_equal(fired2, 1L)
})

test_that("reactive errors in handlers do not crash state$set()", {
  state <- tui_state()
  fake_app <- structure(list(), class = "RtuiApp")
  state$set(".app", fake_app)
  state$.__enclos_env__$private$.reactive <- list(
    count = list(function(v, s, a) stop("oops"))
  )

  # Should not throw
  expect_no_error(state$set("count", 5L))
  expect_equal(state$get("count"), 5L)
})

# ---- Formula binding ----

test_that("formula binding has access to .x, .state, .app", {
  captured <- list()
  state <- tui_state()
  fake_app <- structure(list(), class = "RtuiApp")
  state$set(".app", fake_app)

  # Build a formula binding manually using the internal helper
  f <- ~ {
    captured$x <<- .x
    captured$state_is_state <<- inherits(.state, "RtuiState")
    captured$app_is_app <<- inherits(.app, "RtuiApp")
  }
  fn <- rtui:::make_formula_fn(f, "count")
  state$.__enclos_env__$private$.reactive <- list(count = list(fn))

  state$set("count", 42L)
  expect_equal(captured$x, 42L)
  expect_true(captured$state_is_state)
  expect_true(captured$app_is_app)
})

# ---- tui_app integration ----

test_that("tui_app() accepts reactive parameter", {
  app <- tui_app(
    layout = vstack(text("hi"), id = "root"),
    reactive = reactive(count = "display")
  )
  expect_s3_class(app, "RtuiApp")
  # reactive should be installed in state
  installed <- app$state$.__enclos_env__$private$.reactive
  expect_named(installed, "count")
})

test_that("tui_app() errors on non-reactive object for reactive param", {
  expect_error(
    tui_app(
      layout = vstack(text("hi"), id = "root"),
      reactive = list(count = "display")  # missing class
    ),
    "reactive\\(\\)"
  )
})
