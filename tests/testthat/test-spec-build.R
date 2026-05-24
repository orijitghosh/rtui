test_that("text() creates valid spec", {
  s <- text("hello", id = "t1")
  expect_s3_class(s, "rtui_spec")
  expect_equal(s$kind, "text")
  expect_equal(s$id, "t1")
  expect_equal(s$props$content, "hello")
  expect_null(s$children)
})

test_that("text() rejects non-string content", {
  expect_error(text(123), class = "rtui_spec_error")
  expect_error(text(c("a", "b")), class = "rtui_spec_error")
})

test_that("box() creates valid spec with border", {
  child <- text("inner")
  s <- box(child, border = "round", title = "My Box", id = "b1")
  expect_s3_class(s, "rtui_spec")
  expect_equal(s$kind, "box")
  expect_equal(s$props$border, "round")
  expect_equal(s$props$title, "My Box")
  expect_length(s$children, 1)
  expect_s3_class(s$children[[1]], "rtui_spec")
})

test_that("box() rejects invalid border", {
  expect_error(box(text("x"), border = "squiggly"))
})

test_that("box() rejects non-spec child", {
  expect_error(box("not a spec"), class = "rtui_spec_error")
})

test_that("static() creates valid spec", {
  s <- static("rich text", id = "s1")
  expect_equal(s$kind, "static")
  expect_equal(s$props$content, "rich text")
})

test_that("log_view() creates valid spec", {
  s <- log_view(id = "log", max_lines = 500L)
  expect_equal(s$kind, "log_view")
  expect_equal(s$props$max_lines, 500L)
})

test_that("log_view() rejects bad max_lines", {
  expect_error(log_view(max_lines = -1), class = "rtui_spec_error")
  expect_error(log_view(max_lines = "abc"), class = "rtui_spec_error")
})

test_that("input() creates valid spec", {
  s <- input(placeholder = "type here", value = "init", id = "inp")
  expect_equal(s$kind, "input")
  expect_equal(s$props$placeholder, "type here")
  expect_equal(s$props$value, "init")
})

test_that("button() creates valid spec", {
  s <- button("Click me", id = "btn")
  expect_equal(s$kind, "button")
  expect_equal(s$props$label, "Click me")
})

test_that("button() rejects non-string label", {
  expect_error(button(42), class = "rtui_spec_error")
})

test_that("list_view() creates valid spec", {
  s <- list_view(c("a", "b", "c"), id = "lv")
  expect_equal(s$kind, "list_view")
  expect_equal(s$props$items, c("a", "b", "c"))
})

test_that("list_view() rejects non-character items", {
  expect_error(list_view(1:5), class = "rtui_spec_error")
})

test_that("data_table() creates valid spec", {
  s <- data_table(mtcars, id = "dt")
  expect_equal(s$kind, "data_table")
  expect_true(is.data.frame(s$props$df))
})

test_that("data_table() rejects non-data.frame", {
  expect_error(data_table(list(a = 1)), class = "rtui_spec_error")
})

test_that("vstack() nests children", {
  s <- vstack(text("a"), text("b"), id = "vs")
  expect_equal(s$kind, "vstack")
  expect_length(s$children, 2)
  expect_equal(s$children[[1]]$kind, "text")
  expect_equal(s$children[[2]]$kind, "text")
})

test_that("hstack() nests children", {
  s <- hstack(text("a"), button("b"), id = "hs")
  expect_equal(s$kind, "hstack")
  expect_length(s$children, 2)
})

test_that("grid() validates rows/cols", {
  s <- grid(text("a"), rows = 2, cols = 3, id = "g1")
  expect_equal(s$props$rows, 2L)
  expect_equal(s$props$cols, 3L)

  expect_error(grid(text("a"), rows = -1), class = "rtui_spec_error")
  expect_error(grid(text("a"), cols = 0), class = "rtui_spec_error")
})

test_that("container() works with children", {
  s <- container(text("a"), id = "c1")
  expect_equal(s$kind, "container")
  expect_length(s$children, 1)
})

test_that("containers reject non-spec children", {
  expect_error(vstack("not a spec"), class = "rtui_spec_error")
  expect_error(hstack(42), class = "rtui_spec_error")
  expect_error(container(NULL), class = "rtui_spec_error")
})

test_that("id validation works", {
  expect_error(text("x", id = ""), class = "rtui_spec_error")
  expect_error(text("x", id = 123), class = "rtui_spec_error")
})

test_that("classes are stored correctly", {
  s <- text("x", classes = c("highlight", "bold"))
  expect_equal(s$classes, c("highlight", "bold"))
})

test_that("classes validation rejects non-character", {
  expect_error(text("x", classes = 1:3), class = "rtui_spec_error")
})

test_that("spec-purity: identical args produce identical specs", {
  s1 <- vstack(text("a", id = "t"), box(text("b"), border = "round"), id = "root")
  s2 <- vstack(text("a", id = "t"), box(text("b"), border = "round"), id = "root")
  expect_identical(s1, s2)
})

test_that("deeply nested specs work", {
  s <- vstack(
    hstack(
      box(text("inner", id = "t1"), border = "double", id = "b1"),
      container(
        static("status", id = "s1"),
        id = "c1"
      ),
      id = "row"
    ),
    id = "root"
  )
  expect_s3_class(s, "rtui_spec")
  expect_equal(s$children[[1]]$children[[1]]$kind, "box")
  expect_equal(s$children[[1]]$children[[2]]$children[[1]]$kind, "static")
})
