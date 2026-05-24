# Tests for API ergonomic improvements:
# - All handlers in tui_app()
# - Per-widget-id routing
# - quick_app() constructor
# - data_viewer() / browse_files() constructors
# - state$app active binding

# --- All handlers in tui_app() ---

test_that("tui_app() accepts on_click as function", {
  app <- tui_app(
    layout = vstack(button("Go", id = "go")),
    on_click = function(event, state) state
  )
  expect_s3_class(app, "RtuiApp")
  expect_true(is.function(app$handlers$click))
})

test_that("tui_app() accepts on_change as function", {
  app <- tui_app(
    layout = vstack(input(id = "name")),
    on_change = function(event, state) state
  )
  expect_true(is.function(app$handlers$change))
})

test_that("tui_app() accepts on_timer as function", {
  app <- tui_app(
    layout = vstack(text("hi")),
    on_timer = function(event, state) state
  )
  expect_true(is.function(app$handlers$timer))
})

test_that("tui_app() accepts on_submit as function", {
  app <- tui_app(
    layout = vstack(input(id = "q")),
    on_submit = function(event, state) state
  )
  expect_true(is.function(app$handlers$submit))
})

test_that("tui_app() accepts on_screen_result as function", {
  app <- tui_app(
    layout = vstack(text("hi")),
    on_screen_result = function(event, state) state
  )
  expect_true(is.function(app$handlers$screen_result))
})

# --- Per-widget-id routing ---

test_that("tui_app() accepts on_click as named list", {
  app <- tui_app(
    layout = vstack(
      button("Save", id = "save"),
      button("Cancel", id = "cancel")
    ),
    on_click = list(
      save = function(event, state) state,
      cancel = function(event, state) state
    )
  )
  expect_true(is.list(app$handlers$click))
  expect_true(is.function(app$handlers$click$save))
  expect_true(is.function(app$handlers$click$cancel))
})

test_that("tui_app() accepts on_change as named list", {
  app <- tui_app(
    layout = vstack(
      input(id = "name"),
      input(id = "email")
    ),
    on_change = list(
      name = function(event, state) state,
      email = function(event, state) state
    )
  )
  expect_true(is.list(app$handlers$change))
  expect_length(app$handlers$change, 2)
})

test_that("on_click named list rejects unnamed entries", {
  expect_error(
    tui_app(
      layout = vstack(button("Go", id = "go")),
      on_click = list(function(event, state) state)
    ),
    class = "rtui_spec_error"
  )
})

test_that("on_click named list rejects non-function values", {
  expect_error(
    tui_app(
      layout = vstack(button("Go", id = "go")),
      on_click = list(go = "not a function")
    ),
    class = "rtui_spec_error"
  )
})

test_that("on_click rejects non-function non-list", {
  expect_error(
    tui_app(
      layout = vstack(button("Go", id = "go")),
      on_click = 42
    ),
    class = "rtui_spec_error"
  )
})

# --- state$app active binding ---

test_that("state$app is NULL by default", {
  s <- tui_state()
  expect_null(s$app)
})

test_that("state$app returns the app after .app is set", {
  s <- tui_state()
  s$set(".app", "mock_app")
  expect_equal(s$app, "mock_app")
})

test_that("as_list() excludes internal keys", {
  s <- tui_state()
  s$set("count", 5)
  s$set(".app", "mock_app")
  result <- s$as_list()
  expect_equal(result, list(count = 5))
  expect_null(result[[".app"]])
})

test_that("print() excludes internal keys", {
  s <- tui_state()
  s$set("count", 5)
  s$set(".app", "mock_app")
  # cli output may need type = "message"; capture both
  out <- paste(
    capture.output(print(s), type = "output"),
    capture.output(print(s), type = "message"),
    collapse = "\n"
  )
  expect_false(grepl("\\.app", out))
  expect_true(grepl("count", out))
})

# --- quick_app() ---

test_that("quick_app() is exported and is a function", {
  expect_true(is.function(quick_app))
})

# --- data_viewer() ---

test_that("data_viewer() rejects non-data.frame", {
  expect_error(data_viewer("not a df"), class = "rtui_spec_error")
})

test_that("data_viewer() is exported and is a function", {
  expect_true(is.function(data_viewer))
})

# --- browse_files() ---

test_that("browse_files() rejects bad path", {
  expect_error(browse_files(42), class = "rtui_spec_error")
})

test_that("browse_files() is exported and is a function", {
  expect_true(is.function(browse_files))
})
