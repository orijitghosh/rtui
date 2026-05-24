# Showcase: CSV Data Explorer
#
# Load built-in R datasets, browse with sortable table, view summary stats,
# and plot columns interactively with multiple chart types.
#
# Run from a REAL TERMINAL:
#   & "C:\Program Files\R\R-4.4.3\bin\Rscript.exe" spikes/showcase_csv_explorer.R

Sys.unsetenv("RETICULATE_PYTHON")
Sys.setenv(RETICULATE_PYTHON_ENV = "r-rtui")

library(reticulate)
use_virtualenv("r-rtui", required = TRUE)

devtools::load_all(".")

message("--- CSV Data Explorer ---")
message("Explore data with tables, stats, and charts.")
message("Press q to quit, d to toggle dark mode.")

# --- Helper: compute summary stats ---
compute_summary <- function(df) {
  stats <- list()
  for (col in names(df)) {
    vals <- df[[col]]
    if (is.numeric(vals)) {
      stats[[col]] <- list(
        type = "numeric",
        min = round(min(vals, na.rm = TRUE), 2),
        max = round(max(vals, na.rm = TRUE), 2),
        mean = round(mean(vals, na.rm = TRUE), 2),
        median = round(median(vals, na.rm = TRUE), 2),
        sd = round(sd(vals, na.rm = TRUE), 2),
        na = sum(is.na(vals))
      )
    } else {
      stats[[col]] <- list(
        type = "factor",
        unique = length(unique(vals)),
        top = names(sort(table(vals), decreasing = TRUE))[1],
        na = sum(is.na(vals))
      )
    }
  }
  stats
}

# --- Helper: format summary for display ---
format_summary <- function(stats) {
  lines <- c()
  for (col in names(stats)) {
    s <- stats[[col]]
    if (s$type == "numeric") {
      lines <- c(lines,
        sprintf("[bold cyan]%s[/bold cyan] (numeric)", col),
        sprintf("  Min: %s  Max: %s  Mean: %s  Median: %s  SD: %s  NA: %d",
                s$min, s$max, s$mean, s$median, s$sd, s$na),
        "")
    } else {
      lines <- c(lines,
        sprintf("[bold green]%s[/bold green] (factor)", col),
        sprintf("  Unique: %d  Top: %s  NA: %d", s$unique, s$top, s$na),
        "")
    }
  }
  paste(lines, collapse = "\n")
}

# --- Helper: get numeric columns ---
numeric_cols <- function(df) {
  names(df)[vapply(df, is.numeric, logical(1))]
}

# --- Helper: load dataset and update all views ---
load_dataset <- function(state, df, name) {
  state$set(".data", df)
  state$set(".name", name)

  # Update table
  update(state$app, "data_table", clear_data = TRUE)
  display <- as.list(df)
  for (nm in names(display)) {
    if (is.numeric(display[[nm]])) display[[nm]] <- round(display[[nm]], 2)
    if (is.factor(display[[nm]])) display[[nm]] <- as.character(display[[nm]])
  }
  update(state$app, "data_table", add_rows = display)

  # Update summary
  stats <- compute_summary(df)
  update(state$app, "summary_text", content = format_summary(stats))

  # Status
  num_cols <- numeric_cols(df)
  update(state$app, "status_bar",
         content = sprintf("%s | %d rows x %d cols | Numeric: %s",
                           name, nrow(df), ncol(df),
                           paste(num_cols, collapse = ", ")))

  # Auto-plot first two numeric columns as scatter
  if (length(num_cols) >= 2) {
    plot_scatter(state$app, "chart",
                 x = df[[num_cols[1]]], y = df[[num_cols[2]]],
                 title = paste(name, ":", num_cols[1], "vs", num_cols[2]),
                 color = "cyan",
                 xlabel = num_cols[1], ylabel = num_cols[2])
  }
}

# --- Build the app ---
quick_app(
  title = "CSV Data Explorer",
  dark = TRUE,

  layout = vstack(
    header(),

    # Toolbar
    hstack(
      button("mtcars", id = "btn_mtcars"),
      button("iris", id = "btn_iris"),
      button("airquality", id = "btn_airquality"),
      button("ChickWeight", id = "btn_chick"),
      rule(id = "vsep1"),
      static("Chart:", id = "lbl_chart"),
      select(c("scatter", "line", "bar", "histogram", "box"),
             value = "scatter", prompt = "Chart", id = "sel_chart"),
      button("Plot", id = "btn_plot"),
      id = "toolbar"
    ),

    # Main content: tabs
    tabs(
      tab_pane(
        data_table(
          data.frame(x = character(0)),
          id = "data_table", cursor = "row", zebra_stripes = TRUE, sortable = TRUE
        ),
        title = "Data", id = "tab_data"
      ),
      tab_pane(
        scroll(
          static("Load a dataset to see summary statistics.", id = "summary_text"),
          id = "summary_scroll"
        ),
        title = "Summary", id = "tab_summary"
      ),
      tab_pane(
        text_plot(id = "chart"),
        title = "Chart", id = "tab_chart"
      ),
      id = "main_tabs"
    ),

    # Status
    static("Click a dataset button to explore.", id = "status_bar"),

    footer(),
    id = "root"
  ),

  on_mount = function(event, state) {
    # Auto-load mtcars on start
    df <- mtcars
    df <- cbind(Car = rownames(df), df)
    rownames(df) <- NULL
    set_timer(state$app, 0.1, "auto_load")
    state
  },

  on_timer = function(event, state) {
    if (event$timer_id == "auto_load") {
      tryCatch({
        df <- mtcars
        df <- cbind(Car = rownames(df), df)
        rownames(df) <- NULL
        load_dataset(state, df, "mtcars")
      }, error = function(e) {
        notify(state$app, paste("Error:", conditionMessage(e)), severity = "error")
      })
    }
    state
  },

  on_click = list(
    btn_mtcars = function(event, state) {
      df <- mtcars
      df <- cbind(Car = rownames(df), df)
      rownames(df) <- NULL
      load_dataset(state, df, "mtcars")
      state
    },

    btn_iris = function(event, state) {
      load_dataset(state, iris, "iris")
      state
    },

    btn_airquality = function(event, state) {
      df <- airquality[complete.cases(airquality), ]
      load_dataset(state, df, "airquality")
      state
    },

    btn_chick = function(event, state) {
      load_dataset(state, ChickWeight, "ChickWeight")
      state
    },

    btn_plot = function(event, state) {
      df <- state$get(".data")
      if (is.null(df)) {
        notify(state$app, "Load a dataset first!", severity = "warning")
        return(state)
      }
      name <- state$get(".name", "data")
      num_cols <- numeric_cols(df)

      chart_type <- collect_form(state$app, "sel_chart")$sel_chart
      if (is.null(chart_type)) chart_type <- "scatter"

      if (chart_type == "histogram" && length(num_cols) >= 1) {
        col <- num_cols[1]
        plot_hist(state$app, "chart",
                  data = df[[col]], bins = 15L,
                  title = paste(name, "-", col, "Distribution"),
                  color = "cyan", xlabel = col)

      } else if (chart_type == "box" && length(num_cols) >= 2) {
        n_cols <- min(5, length(num_cols))
        grps <- lapply(num_cols[1:n_cols], function(c) df[[c]])
        names(grps) <- num_cols[1:n_cols]
        plot_box(state$app, "chart",
                 data = grps,
                 title = paste(name, "- Box Plot"),
                 colors = c("red", "blue", "green", "yellow", "magenta"))

      } else if (chart_type == "bar" && length(num_cols) >= 1) {
        col <- num_cols[1]
        n <- min(20, nrow(df))
        labels <- if ("Car" %in% names(df)) {
          df$Car[1:n]
        } else {
          as.character(1:n)
        }
        plot_bar(state$app, "chart",
                 labels = labels, values = df[[col]][1:n],
                 title = paste(name, "-", col),
                 color = "green", ylabel = col)

      } else if (chart_type == "line" && length(num_cols) >= 1) {
        col <- num_cols[1]
        plot_line(state$app, "chart",
                  x = seq_len(nrow(df)), y = df[[col]],
                  title = paste(name, "-", col),
                  color = "blue", marker = "braille",
                  xlabel = "Row", ylabel = col)

      } else if (length(num_cols) >= 2) {
        plot_scatter(state$app, "chart",
                     x = df[[num_cols[1]]], y = df[[num_cols[2]]],
                     title = paste(name, ":", num_cols[1], "vs", num_cols[2]),
                     color = "magenta",
                     xlabel = num_cols[1], ylabel = num_cols[2])

      } else {
        notify(state$app, "Need numeric columns to plot", severity = "warning")
      }
      state
    }
  ),

  bindings = list(
    binding("q", "quit_app", "Quit", priority = TRUE),
    binding("escape", "quit_app", "Quit", priority = TRUE),
    binding("d", "toggle_dark", "Dark mode", priority = TRUE)
  ),
  on_key = function(event, state) {
    if (event$key == "q" || event$key == "escape") return(quit(state))
    state
  },
  on_action = function(event, state) {
    if (event$value == "quit_app") return(quit(state))
    if (event$value == "toggle_dark") dark_toggle(state$app)
    state
  },

  css = paste0(
    tui_theme("nord"),
    "
    #toolbar { height: 3; align: left middle; padding: 0 1; }
    #vsep1 { width: 1; }
    #lbl_chart { width: auto; padding: 0 1; }
    #sel_chart { width: 15; }
    #chart { height: 1fr; }
    #summary_scroll { height: 1fr; }
    #summary_text { padding: 1 2; }
    #status_bar { height: 1; dock: bottom; background: #3b4252;
                  color: #88c0d0; padding: 0 1; }
    Button { margin: 0 1; }
    DataTable { height: 1fr; }
    "
  )
)

message("--- CSV Explorer exited ---")
