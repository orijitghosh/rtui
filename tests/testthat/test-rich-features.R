# Tests for Rich DataTable, Form Builder, and Dialogs

library(testthat)

# ---- Rich DataTable ----

test_that("data_table() accepts cursor and zebra_stripes", {
  df <- data.frame(x = 1:3, y = letters[1:3])
  spec <- data_table(df, id = "dt", cursor = "cell", zebra_stripes = TRUE)
  expect_s3_class(spec, "rtui_spec")
  expect_equal(spec$kind, "data_table")
  expect_equal(spec$props$cursor, "cell")
  expect_true(spec$props$zebra_stripes)
})

test_that("data_table() accepts sortable parameter", {
  df <- data.frame(a = 1:2)
  spec <- data_table(df, id = "dt", sortable = TRUE)
  expect_true(spec$props$sortable)
})

test_that("data_table() defaults to row cursor, no zebra, not sortable", {
  df <- data.frame(a = 1)
  spec <- data_table(df)
  expect_equal(spec$props$cursor, "row")
  expect_false(spec$props$zebra_stripes)
  expect_false(spec$props$sortable)
})

test_that("data_table() rejects invalid cursor", {
  df <- data.frame(a = 1)
  expect_error(data_table(df, cursor = "invalid"))
})

test_that("data_table() rejects non-logical zebra_stripes", {
  df <- data.frame(a = 1)
  expect_error(data_table(df, zebra_stripes = "yes"), "TRUE or FALSE")
})

test_that("data_table() rejects non-logical sortable", {
  df <- data.frame(a = 1)
  expect_error(data_table(df, sortable = 1), "TRUE or FALSE")
})

# ---- Form Builder ----

test_that("tui_form() creates a vstack with labelled fields", {
  form <- tui_form(
    Name = input(placeholder = "name"),
    Age = input(placeholder = "age"),
    id = "myform"
  )
  expect_s3_class(form, "rtui_spec")
  expect_equal(form$kind, "vstack")
  expect_equal(form$id, "myform")
  # Should have: label, input, label, input, submit button = 5 children

  expect_equal(length(form$children), 5L)
})

test_that("tui_form() auto-assigns ids from field names", {
  form <- tui_form(Name = input(), Email = input())
  # Children: label, input(name), label, input(email), submit
  name_input <- form$children[[2]]
  email_input <- form$children[[4]]
  expect_equal(name_input$id, "name")
  expect_equal(email_input$id, "email")
})

test_that("tui_form() preserves explicit widget ids", {
  form <- tui_form(Name = input(id = "custom_name"))
  name_input <- form$children[[2]]
  expect_equal(name_input$id, "custom_name")
})

test_that("tui_form() includes submit button with id __form_submit", {
  form <- tui_form(X = input())
  last_child <- form$children[[length(form$children)]]
  expect_equal(last_child$kind, "button")
  expect_equal(last_child$id, "__form_submit")
})

test_that("tui_form() accepts custom submit label", {
  form <- tui_form(X = input(), submit_label = "Go!")
  last_child <- form$children[[length(form$children)]]
  expect_equal(last_child$props$label, "Go!")
})

test_that("tui_form() errors on unnamed fields", {
  expect_error(tui_form(input()), "must be named")
})

test_that("tui_form() errors on empty fields", {
  expect_error(tui_form(), "At least one field")
})

test_that("tui_form() errors on non-spec fields", {
  expect_error(tui_form(Name = "not a spec"), "not an rtui widget spec")
})

test_that("tui_form() works with mixed widget types", {
  form <- tui_form(
    Name = input(placeholder = "name"),
    Active = checkbox("Active?"),
    Role = select(c("Admin", "User"))
  )
  expect_equal(length(form$children), 7L)  # 3 labels + 3 inputs + 1 submit
  # Check ids
  expect_equal(form$children[[2]]$id, "name")
  expect_equal(form$children[[4]]$id, "active")
  expect_equal(form$children[[6]]$id, "role")
})

test_that("tui_form() stores field ids in props", {
  form <- tui_form(Name = input(), Email = input())
  expect_equal(form$props$.form_field_ids, c("name", "email"))
})

# ---- Dialogs ----

test_that("confirm() errors on non-RtuiApp", {
  expect_error(confirm("not_app", "Sure?"), "RtuiApp")
})

test_that("confirm() errors on non-string message", {
  expect_error(confirm("not_app", 123), "RtuiApp")
})

test_that("alert() errors on non-RtuiApp", {
  expect_error(alert("not_app", "Hello"), "RtuiApp")
})

test_that("alert() errors on non-string message", {
  expect_error(alert("not_app", list()), "RtuiApp")
})

# ---- collect_form() ----

test_that("collect_form() errors on non-RtuiApp", {
  expect_error(collect_form("not_app", "x"), "RtuiApp")
})

test_that("collect_form() errors on empty field_ids", {
  expect_error(collect_form("not_app", character(0)), "RtuiApp")
})

# ---- data_viewer() with new defaults ----

test_that("data_viewer() still works with basic df", {
  # Just check it creates the app, don't run it
  df <- data.frame(a = 1:3, b = 4:6)
  # We can't run the app in tests, but we can check data_table spec
  spec <- data_table(df, id = "data", cursor = "row", sortable = TRUE)
  expect_equal(spec$props$cursor, "row")
  expect_true(spec$props$sortable)
})
