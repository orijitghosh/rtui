#' Interactive data viewer
#'
#' Opens a full-screen interactive data table for exploring a data.frame.
#' Supports sorting by clicking column headers. Press `q` or `escape` to quit.
#'
#' **Important:** Must be run from a real terminal (not RStudio, R GUI, or
#' Jupyter). Save your code as a `.R` file and run with `Rscript`.
#'
#' @param df A data.frame to display.
#' @param title Optional title for the app.
#' @param dark Use dark mode (default TRUE).
#' @return The data.frame (invisibly).
#' @export
data_viewer <- function(df, title = NULL, dark = TRUE) {
  if (!is.data.frame(df)) {
    abort_spec("`df` must be a data.frame.")
  }
  if (is.null(title)) {
    title <- paste0("Data Viewer: ", deparse(substitute(df)))
  }

  quick_app(
    title = title,
    dark = dark,
    layout = vstack(
      header(),
      data_table(df, id = "data", sortable = TRUE, zebra_stripes = TRUE),
      text(
        paste0(nrow(df), " rows x ", ncol(df), " cols"),
        id = "status"
      ),
      footer(),
      id = "root"
    ),
    bindings = list(
      binding("q", "quit_app", "Quit", priority = TRUE),
      binding("escape", "quit_app", "Quit", priority = TRUE)
    ),
    on_action = function(event, state) {
      if (event$value == "quit_app") return(quit())
      state
    },
    css = "
      #data { height: 1fr; }
      #status { height: 1; dock: bottom; background: $accent; color: $text; padding: 0 1; }
    "
  )

  invisible(df)
}


#' Interactive file browser
#'
#' Opens a terminal file browser rooted at the given path. Click a file to
#' see its path displayed. Press `q` or `escape` to quit. Returns the last
#' selected file path (or NULL).
#'
#' **Important:** Must be run from a real terminal (not RStudio, R GUI, or
#' Jupyter). Save your code as a `.R` file and run with `Rscript`.
#'
#' @param path Root directory to browse (default: current directory).
#' @param title Optional title for the app.
#' @param dark Use dark mode (default TRUE).
#' @return The path of the last selected file (or `NULL`), invisibly.
#' @export
browse_files <- function(path = ".", title = NULL, dark = TRUE) {
  if (!is.character(path) || length(path) != 1L) {
    abort_spec("`path` must be a single character string.")
  }
  if (is.null(title)) {
    title <- paste0("Browse: ", normalizePath(path, mustWork = FALSE))
  }

  quick_app(
    title = title,
    dark = dark,
    layout = vstack(
      header(),
      directory_tree(path = path, id = "tree"),
      text("Select a file...", id = "status"),
      footer(),
      id = "root"
    ),
    on_click = list(
      tree = function(event, state) {
        p <- if (is.list(event$value)) event$value$path else NULL
        if (!is.null(p)) {
          state$set("selected", p)
          update(state$app, "status", content = paste0("Selected: ", p))
        }
        state
      }
    ),
    bindings = list(
      binding("q", "quit_app", "Quit", priority = TRUE),
      binding("escape", "quit_app", "Quit", priority = TRUE)
    ),
    on_action = function(event, state) {
      if (event$value == "quit_app") return(quit(state$get("selected")))
      state
    },
    css = "
      #tree { height: 1fr; }
      #status { height: 1; dock: bottom; background: $accent; color: $text; padding: 0 1; }
    "
  )
}
