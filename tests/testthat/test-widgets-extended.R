test_that("checkbox() creates valid spec", {
  s <- checkbox("Accept terms", value = TRUE, id = "cb1")
  expect_s3_class(s, "rtui_spec")
  expect_equal(s$kind, "checkbox")
  expect_equal(s$props$label, "Accept terms")
  expect_true(s$props$value)
})

test_that("checkbox() rejects bad args", {
  expect_error(checkbox(42), class = "rtui_spec_error")
  expect_error(checkbox("ok", value = "yes"), class = "rtui_spec_error")
})

test_that("radio_button() creates valid spec", {
  s <- radio_button("Option A", id = "rb1")
  expect_equal(s$kind, "radio_button")
  expect_false(s$props$value)
})

test_that("radio_set() wraps radio buttons", {
  s <- radio_set(
    radio_button("A", id = "a"),
    radio_button("B", id = "b"),
    id = "rs"
  )
  expect_equal(s$kind, "radio_set")
  expect_length(s$children, 2)
})

test_that("select() creates valid spec", {
  s <- select(c("red", "green", "blue"), id = "color")
  expect_equal(s$kind, "select")
  expect_equal(s$props$options, c("red", "green", "blue"))
  expect_equal(s$props$prompt, "Select...")
})

test_that("select() accepts named options", {
  s <- select(c(r = "Red", g = "Green"), value = "r", id = "sel")
  expect_equal(s$props$value, "r")
})

test_that("switch_input() creates valid spec", {
  s <- switch_input(value = TRUE, id = "sw")
  expect_equal(s$kind, "switch")
  expect_true(s$props$value)
})

test_that("text_area() creates valid spec", {
  s <- text_area("hello\nworld", language = "python", id = "ta")
  expect_equal(s$kind, "text_area")
  expect_equal(s$props$value, "hello\nworld")
  expect_equal(s$props$language, "python")
})

test_that("option_list() creates valid spec", {
  s <- option_list(c("one", "two", "three"), id = "ol")
  expect_equal(s$kind, "option_list")
  expect_equal(s$props$items, c("one", "two", "three"))
})

test_that("selection_list() creates valid spec", {
  s <- selection_list(c("a", "b"), id = "sl")
  expect_equal(s$kind, "selection_list")
})

test_that("tabs() and tab_pane() create valid specs", {
  s <- tabs(
    tab_pane("Tab 1", text("Content 1", id = "t1"), id = "p1"),
    tab_pane("Tab 2", text("Content 2", id = "t2"), id = "p2"),
    id = "mytabs"
  )
  expect_equal(s$kind, "tabs")
  expect_length(s$children, 2)
  expect_equal(s$children[[1]]$kind, "tab_pane")
  expect_equal(s$children[[1]]$props$title, "Tab 1")
})

test_that("header() creates valid spec", {
  s <- header(show_clock = TRUE, id = "hdr")
  expect_equal(s$kind, "header")
  expect_true(s$props$show_clock)
})

test_that("footer() creates valid spec", {
  s <- footer(id = "ftr")
  expect_equal(s$kind, "footer")
})

test_that("collapsible() creates valid spec", {
  s <- collapsible("Details", text("Hidden content", id = "hc"),
                   collapsed = FALSE, id = "coll")
  expect_equal(s$kind, "collapsible")
  expect_equal(s$props$title, "Details")
  expect_false(s$props$collapsed)
  expect_length(s$children, 1)
})

test_that("content_switcher() creates valid spec", {
  s <- content_switcher(
    text("Page 1", id = "p1"),
    text("Page 2", id = "p2"),
    initial = "p1", id = "cs"
  )
  expect_equal(s$kind, "content_switcher")
  expect_equal(s$props$initial, "p1")
})

test_that("tree() creates valid spec", {
  s <- tree("Root", data = list(a = 1, b = list(c = 2)), id = "tr")
  expect_equal(s$kind, "tree")
  expect_equal(s$props$label, "Root")
})

test_that("markdown() creates valid spec", {
  s <- markdown("# Hello\n\nWorld", id = "md")
  expect_equal(s$kind, "markdown")
  expect_equal(s$props$content, "# Hello\n\nWorld")
})

test_that("progress_bar() creates valid spec", {
  s <- progress_bar(total = 200, progress = 50, id = "pb")
  expect_equal(s$kind, "progress_bar")
  expect_equal(s$props$total, 200)
  expect_equal(s$props$progress, 50)
})

test_that("progress_bar() rejects bad total", {
  expect_error(progress_bar(total = -1), class = "rtui_spec_error")
})

test_that("sparkline() creates valid spec", {
  s <- sparkline(c(1, 4, 2, 7, 3), id = "sp")
  expect_equal(s$kind, "sparkline")
  expect_equal(s$props$data, c(1, 4, 2, 7, 3))
})

test_that("sparkline() rejects non-numeric", {
  expect_error(sparkline("abc"), class = "rtui_spec_error")
})

test_that("rule() creates valid spec", {
  s <- rule(label = "Section", id = "r1")
  expect_equal(s$kind, "rule")
  expect_equal(s$props$label, "Section")
})

test_that("rule() works without label", {
  s <- rule()
  expect_equal(s$kind, "rule")
  expect_null(s$props$label)
})

test_that("loading() creates valid spec", {
  s <- loading(id = "ld")
  expect_equal(s$kind, "loading")
})

test_that("digits() creates valid spec", {
  s <- digits("12:34", id = "dg")
  expect_equal(s$kind, "digits")
  expect_equal(s$props$value, "12:34")
})

test_that("placeholder() creates valid spec", {
  s <- placeholder("Coming soon", id = "ph")
  expect_equal(s$kind, "placeholder")
  expect_equal(s$props$label, "Coming soon")
})

test_that("pretty_table() creates valid spec", {
  s <- pretty_table(head(mtcars, 3), title = "Cars", id = "pt")
  expect_equal(s$kind, "pretty_table")
  expect_true(is.data.frame(s$props$df))
  expect_equal(s$props$title, "Cars")
})

test_that("scroll() creates valid spec", {
  s <- scroll(text("content", id = "c"), id = "sc")
  expect_equal(s$kind, "scroll")
  expect_length(s$children, 1)
})

test_that("center() creates valid spec", {
  s <- center(text("centered", id = "c"), id = "ct")
  expect_equal(s$kind, "center")
})

test_that("middle() creates valid spec", {
  s <- middle(text("middled", id = "c"), id = "md")
  expect_equal(s$kind, "middle")
})

# --- Phase 1 additions ---

test_that("directory_tree() creates valid spec", {
  s <- directory_tree(path = "/tmp", id = "dt")
  expect_s3_class(s, "rtui_spec")
  expect_equal(s$kind, "directory_tree")
  expect_equal(s$props$path, "/tmp")
})

test_that("directory_tree() defaults to current dir", {
  s <- directory_tree()
  expect_equal(s$props$path, ".")
})

test_that("directory_tree() rejects bad path", {
  expect_error(directory_tree(path = 42), class = "rtui_spec_error")
})

test_that("masked_input() creates valid spec", {
  s <- masked_input(template = "999-999-9999", id = "phone")
  expect_s3_class(s, "rtui_spec")
  expect_equal(s$kind, "masked_input")
  expect_equal(s$props$template, "999-999-9999")
})

test_that("masked_input() accepts value and placeholder", {
  s <- masked_input("AA99", value = "AB12", placeholder = "Enter code", id = "mi")
  expect_equal(s$props$value, "AB12")
  expect_equal(s$props$placeholder, "Enter code")
})

test_that("masked_input() rejects bad template", {
  expect_error(masked_input(42), class = "rtui_spec_error")
})

test_that("tooltip is stored in props for button", {
  s <- button("Click", id = "b", tooltip = "Does a thing")
  expect_equal(s$props$tooltip, "Does a thing")
})

test_that("tooltip is stored in props for input", {
  s <- input(id = "i", tooltip = "Enter text here")
  expect_equal(s$props$tooltip, "Enter text here")
})

test_that("tooltip is stored in props for text", {
  s <- text("Hello", id = "t", tooltip = "Greeting")
  expect_equal(s$props$tooltip, "Greeting")
})

test_that("tooltip is NULL by default", {
  s <- button("Click", id = "b")
  expect_null(s$props$tooltip)
})

test_that("tui_app accepts title and sub_title", {
  app <- tui_app(
    layout = text("hi", id = "t"),
    title = "My App",
    sub_title = "v1.0"
  )
  expect_equal(app$title, "My App")
  expect_equal(app$sub_title, "v1.0")
})

test_that("tui_app accepts dark mode flag", {
  app <- tui_app(layout = text("hi", id = "t"), dark = FALSE)
  expect_false(app$dark)
})

test_that("tui_app rejects bad title", {
  expect_error(
    tui_app(layout = text("hi", id = "t"), title = 42),
    class = "rtui_spec_error"
  )
})

test_that("tui_app rejects bad dark", {
  expect_error(
    tui_app(layout = text("hi", id = "t"), dark = "yes"),
    class = "rtui_spec_error"
  )
})

# --- Bindings ---

test_that("binding() creates valid binding", {
  b <- binding("q", "quit", "Quit the app")
  expect_s3_class(b, "rtui_binding")
  expect_equal(b$key, "q")
  expect_equal(b$action, "quit")
  expect_equal(b$description, "Quit the app")
})

test_that("binding() rejects bad key", {
  expect_error(binding("", "quit"), class = "rtui_spec_error")
  expect_error(binding(42, "quit"), class = "rtui_spec_error")
})

test_that("binding() rejects bad action", {
  expect_error(binding("q", ""), class = "rtui_spec_error")
  expect_error(binding("q", 42), class = "rtui_spec_error")
})

test_that("tui_app accepts bindings", {
  b <- list(binding("q", "quit", "Quit"))
  app <- tui_app(
    layout = text("hi", id = "t"),
    bindings = b,
    on_action = function(event, state) state
  )
  expect_length(app$bindings, 1)
  expect_equal(app$bindings[[1]]$key, "q")
})

test_that("tui_app rejects bad bindings", {
  expect_error(
    tui_app(layout = text("hi", id = "t"), bindings = list("not_a_binding")),
    class = "rtui_spec_error"
  )
})

# --- Screens ---

test_that("tui_screen() creates valid screen spec", {
  s <- tui_screen(layout = text("Hello", id = "t"))
  expect_s3_class(s, "rtui_screen_spec")
  expect_s3_class(s$layout, "rtui_spec")
})

test_that("tui_screen() accepts css", {
  s <- tui_screen(layout = text("Hello", id = "t"), css = "#t { color: red; }")
  expect_equal(s$css, "#t { color: red; }")
})

test_that("tui_screen() rejects bad layout", {
  expect_error(tui_screen(layout = "not_spec"), class = "rtui_spec_error")
})

# --- Input validators ---

test_that("input() accepts validators", {
  s <- input(id = "num", validators = c("number", "integer"))
  expect_equal(s$props$validators, c("number", "integer"))
})

test_that("input() accepts regex validators", {
  s <- input(id = "pat", validators = "regex:^[A-Z]+$")
  expect_equal(s$props$validators, "regex:^[A-Z]+$")
})

test_that("input() rejects bad validators", {
  expect_error(input(id = "x", validators = 42), class = "rtui_spec_error")
})
