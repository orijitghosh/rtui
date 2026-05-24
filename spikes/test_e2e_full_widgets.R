# End-to-end test: showcase of all major widget types.
#
# Run from a REAL TERMINAL:
#   & "C:\Program Files\R\R-4.4.3\bin\Rscript.exe" spikes/test_e2e_full_widgets.R

Sys.unsetenv("RETICULATE_PYTHON")
Sys.setenv(RETICULATE_PYTHON_ENV = "r-rtui")

library(reticulate)
use_virtualenv("r-rtui", required = TRUE)

devtools::load_all(".")

app <- tui_app(
  layout = vstack(
    header(show_clock = TRUE),
    tabs(
      tab_pane("Forms",
        vstack(
          hstack(
            vstack(
              text("Form Controls", id = "form_title"),
              input(placeholder = "Type something...", id = "inp"),
              checkbox("Enable notifications", id = "cb"),
              switch_input(id = "sw"),
              rule(label = "Options"),
              radio_set(
                radio_button("Small", id = "sz_s"),
                radio_button("Medium", value = TRUE, id = "sz_m"),
                radio_button("Large", id = "sz_l"),
                id = "size"
              ),
              select(c("Red", "Green", "Blue"), prompt = "Pick a color", id = "color"),
              button("Submit", id = "submit"),
              id = "form_col"
            ),
            vstack(
              text("Event Log", id = "log_title"),
              static("Events will appear here...", id = "event_log"),
              id = "log_col"
            ),
            id = "form_row"
          ),
          id = "forms_tab"
        ),
        id = "tab_forms"
      ),
      tab_pane("Data",
        vstack(
          data_table(head(mtcars, 8), id = "table"),
          sparkline(c(1, 4, 2, 8, 5, 3, 7, 6, 9, 2), id = "spark"),
          id = "data_tab"
        ),
        id = "tab_data"
      ),
      tab_pane("Tree",
        tree("File System", data = list(
          src = list("app.R", "utils.R", "widgets.R"),
          tests = list("test-spec.R", "test-state.R"),
          inst = list(
            python = list("app.py", "factory.py"),
            examples = list("01-hello.R", "02-list-detail.R")
          )
        ), id = "filetree"),
        id = "tab_tree"
      ),
      tab_pane("Markdown",
        markdown(
          paste(
            "# rtui Widget Showcase",
            "",
            "This tab demonstrates **Markdown** rendering.",
            "",
            "- Supports *rich text*",
            "- Lists and headers",
            "- `code blocks`",
            "",
            "```r",
            "library(rtui)",
            "app <- tui_app(layout = text('hello'))",
            "```",
            sep = "\n"
          ),
          id = "md_content"
        ),
        id = "tab_md"
      ),
      id = "main_tabs"
    ),
    footer(),
    id = "root"
  ),
  on_key = function(event, state) {
    if (event$key == "q") return(quit(state))
    state
  },
  on_mount = function(event, state) {
    state$set("events", 0L)
    state
  },
  css = "
    #form_col { width: 1fr; }
    #log_col { width: 1fr; }
  "
)

app$handlers$change <- function(event, state) {
  n <- state$get("events", 0L) + 1L
  state$set("events", n)
  if (!is.null(event$widget_id)) {
    val <- if (is.list(event$value)) {
      paste(names(event$value), event$value, sep = "=", collapse = ", ")
    } else {
      as.character(event$value)
    }
    msg <- sprintf("[%d] %s changed: %s", n, event$widget_id, val)
    update(app, "event_log", content = msg)
  }
  state
}

app$handlers$click <- function(event, state) {
  n <- state$get("events", 0L) + 1L
  state$set("events", n)
  if (!is.null(event$widget_id)) {
    msg <- sprintf("[%d] %s clicked", n, event$widget_id)
    update(app, "event_log", content = msg)
  }
  state
}

message("--- Launching full widget showcase (q to quit, Tab to switch tabs) ---")
result <- app$run()
message(sprintf("--- App exited. Total events: %s ---", result$get("events", 0L)))
message("--- SUCCESS ---")
