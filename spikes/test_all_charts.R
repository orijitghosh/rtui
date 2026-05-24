# Showcase: All chart types + themes
#
# Run from a REAL TERMINAL:
#   & "C:\Program Files\R\R-4.4.3\bin\Rscript.exe" spikes/test_all_charts.R

Sys.unsetenv("RETICULATE_PYTHON")
Sys.setenv(RETICULATE_PYTHON_ENV = "r-rtui")

library(reticulate)
use_virtualenv("r-rtui", required = TRUE)

devtools::load_all(".")

message("--- All Charts + Themes Demo ---")
message("Click buttons to switch charts. Use theme selector to change colours.")
message("Press q/Escape to quit.")

# Sample data
cities <- c("Tokyo", "London", "New York", "Sydney", "Mumbai")
temps  <- c(31, 24, 30, 27, 34)

quick_app(
  title = "Chart Gallery",
  dark = TRUE,

  layout = vstack(
    header(),
    hstack(
      static("Theme:", id = "theme_label"),
      select(list_themes(), value = "dracula", prompt = "Pick theme", id = "theme_sel"),
      id = "theme_bar"
    ),
    text_plot(id = "chart"),
    hstack(
      button("Bar", id = "btn_bar"),
      button("Line", id = "btn_line"),
      button("Scatter", id = "btn_scatter"),
      button("Histogram", id = "btn_hist"),
      button("Box", id = "btn_box"),
      button("Stacked", id = "btn_stacked"),
      button("Grouped", id = "btn_grouped"),
      button("Heatmap", id = "btn_heatmap"),
      button("Error", id = "btn_error"),
      button("Event", id = "btn_event"),
      id = "toolbar"
    ),
    footer(),
    id = "root"
  ),

  on_mount = function(event, state) {
    plot_bar(state$app, "chart", labels = cities, values = temps,
             title = "Peak Summer Temperatures", color = "red", ylabel = "Temp (C)")
    state
  },

  on_click = list(
    btn_bar = function(event, state) {
      plot_bar(state$app, "chart", labels = cities, values = temps,
               title = "Bar Chart", color = "red", ylabel = "Temp")
      state
    },
    btn_line = function(event, state) {
      x <- 1:20
      y <- sin(x * pi / 5) * 10 + 20
      plot_line(state$app, "chart", x = x, y = y,
                title = "Line Chart", color = "blue", marker = "braille",
                xlabel = "X", ylabel = "Y")
      state
    },
    btn_scatter = function(event, state) {
      set.seed(42)
      x <- rnorm(60, 5, 2)
      y <- x * 1.5 + rnorm(60)
      plot_scatter(state$app, "chart", x = x, y = y,
                   title = "Scatter Plot", color = "green",
                   xlabel = "X", ylabel = "Y")
      state
    },
    btn_hist = function(event, state) {
      set.seed(1)
      plot_hist(state$app, "chart", data = rnorm(200, 50, 10), bins = 15L,
                title = "Histogram", color = "cyan", xlabel = "Value")
      state
    },
    btn_box = function(event, state) {
      set.seed(1)
      grps <- list(Eng = rnorm(50, 95, 15), Mktg = rnorm(50, 72, 10),
                   Sales = rnorm(50, 68, 12))
      plot_box(state$app, "chart", data = grps,
               title = "Box Plot: Salary by Dept",
               colors = c("red", "blue", "green"), ylabel = "Salary (k)")
      state
    },
    btn_stacked = function(event, state) {
      plot_stacked_bar(state$app, "chart",
                       labels = c("Q1", "Q2", "Q3", "Q4"),
                       data = list(ProductA = c(20, 35, 30, 25),
                                   ProductB = c(15, 20, 25, 30)),
                       title = "Stacked Bar", colors = c("blue", "red"),
                       ylabel = "Revenue")
      state
    },
    btn_grouped = function(event, state) {
      plot_multiple_bar(state$app, "chart",
                        labels = c("Q1", "Q2", "Q3", "Q4"),
                        data = list(East = c(20, 35, 30, 25),
                                    West = c(15, 20, 25, 30)),
                        title = "Grouped Bar", colors = c("green", "magenta"),
                        ylabel = "Sales")
      state
    },
    btn_heatmap = function(event, state) {
      set.seed(1)
      m <- matrix(runif(25, 0, 100), nrow = 5)
      plot_heatmap(state$app, "chart", matrix = m,
                   title = "Heatmap")
      state
    },
    btn_error = function(event, state) {
      x <- 1:6
      y <- c(10, 15, 13, 17, 14, 18)
      plot_error(state$app, "chart", x = x, y = y,
                 yerr = c(2, 3, 1.5, 2.5, 2, 3),
                 title = "Error Bars", color = "red",
                 xlabel = "Experiment", ylabel = "Result")
      state
    },
    btn_event = function(event, state) {
      events <- c(2, 5, 8, 12, 15, 19)
      plot_event(state$app, "chart", positions = events,
                 title = "Event Plot: Incidents", color = "yellow",
                 xlabel = "Day")
      state
    }
  ),

  on_change = list(
    theme_sel = function(event, state) {
      theme_name <- event$value
      if (!is.null(theme_name) && theme_name %in% list_themes()) {
        notify(state$app, paste0("Theme: ", theme_name), severity = "info")
      }
      state
    }
  ),

  bindings = list(
    binding("q", "quit_app", "Quit", priority = TRUE),
    binding("escape", "quit_app", "Quit", priority = TRUE)
  ),
  on_key = function(event, state) {
    if (event$key == "q" || event$key == "escape") return(quit(state))
    state
  },
  on_action = function(event, state) {
    if (event$value == "quit_app") return(quit(state))
    state
  },

  css = paste0(
    tui_theme("dracula"),
    "
    #chart { height: 1fr; }
    #toolbar { height: 3; align: center middle; }
    #theme_bar { height: 3; align: left middle; padding: 0 1; }
    #theme_label { width: 8; }
    #theme_sel { width: 25; }
    Button { margin: 0 1; min-width: 8; }
    "
  )
)

message("--- All Charts Demo exited ---")
