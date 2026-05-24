test_that("event_key wraps a function", {
  h <- event_key(function(event, state) state)
  expect_s3_class(h, "rtui_key_handler")
  expect_s3_class(h, "rtui_handler")
  expect_true(is.function(h))
})

test_that("event_change wraps a function", {
  h <- event_change(function(event, state) state)
  expect_s3_class(h, "rtui_change_handler")
  expect_s3_class(h, "rtui_handler")
})

test_that("event_click wraps a function", {
  h <- event_click(function(event, state) state)
  expect_s3_class(h, "rtui_click_handler")
  expect_s3_class(h, "rtui_handler")
})

test_that("event wrappers reject non-functions", {
  expect_error(event_key("not a function"), class = "rtui_spec_error")
  expect_error(event_change(42), class = "rtui_spec_error")
  expect_error(event_click(NULL), class = "rtui_spec_error")
})

test_that("quit() creates sentinel", {
  q <- quit()
  expect_s3_class(q, "rtui_quit")
  expect_null(q$result)
})

test_that("quit() carries a result", {
  q <- quit(list(final = TRUE))
  expect_s3_class(q, "rtui_quit")
  expect_equal(q$result, list(final = TRUE))
})

test_that("event handlers are callable", {
  h <- event_key(function(event, state) {
    state$set("pressed", event$key)
    state
  })
  s <- tui_state()
  event <- list(key = "q", type = "key")
  result <- h(event, s)
  expect_equal(result$get("pressed"), "q")
})
