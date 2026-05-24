# Showcase: Text Plots — bar, line, scatter, histogram in the terminal
#
# Run from a REAL TERMINAL:
#   & "C:\Program Files\R\R-4.4.3\bin\Rscript.exe" spikes/test_text_plot.R

Sys.unsetenv("RETICULATE_PYTHON")
Sys.setenv(RETICULATE_PYTHON_ENV = "r-rtui")

library(reticulate)
use_virtualenv("r-rtui", required = TRUE)

devtools::load_all(".")

message("--- Text Plot Demo ---")
message("Click the buttons to switch chart types. Press q/Escape to quit.")

# Sample data
cities <- c("Tokyo", "London", "New York", "Sydney", "Mumbai")
temps  <- c(31, 24, 30, 27, 34)
months <- 1:12
sin_data <- sin(months * pi / 6) * 10 + 20
salary_data <- c(95, 72, 105, 68, 98, 75, 71, 110, 69, 82, 102, 73, 77, 99, 71)

quick_app(
  title = "Text Plot Demo",
  dark = TRUE,

  layout = vstack(
    header(),
    text_plot(id = "chart"),
    hstack(
      button("Bar Chart", id = "btn_bar"),
      button("Line Chart", id = "btn_line"),
      button("Scatter", id = "btn_scatter"),
      button("Histogram", id = "btn_hist"),
      id = "toolbar"
    ),
    footer(),
    id = "root"
  ),

  on_mount = function(event, state) {
    # Draw initial bar chart
    plot_bar(state$app, "chart",
             labels = cities, values = temps,
             title = "Peak Summer Temperatures",
             color = "red",
             ylabel = "Temp (C)")
    state
  },

  on_click = list(
    btn_bar = function(event, state) {
      plot_bar(state$app, "chart",
               labels = cities, values = temps,
               title = "Peak Summer Temperatures",
               color = "red",
               ylabel = "Temp (C)")
      state
    },
    btn_line = function(event, state) {
      plot_line(state$app, "chart",
                x = months, y = sin_data,
                title = "Monthly Temperature Wave",
                color = "blue",
                marker = "braille",
                xlabel = "Month", ylabel = "Temp (C)")
      state
    },
    btn_scatter = function(event, state) {
      set.seed(42)
      x <- rnorm(50, mean = 5, sd = 2)
      y <- x * 1.5 + rnorm(50, sd = 1)
      plot_scatter(state$app, "chart",
                   x = x, y = y,
                   title = "Salary vs Experience",
                   color = "green",
                   xlabel = "Years", ylabel = "Salary (k)")
      state
    },
    btn_hist = function(event, state) {
      plot_hist(state$app, "chart",
                data = salary_data,
                bins = 8L,
                title = "Salary Distribution",
                color = "cyan",
                xlabel = "Salary (k)", ylabel = "Count")
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

  css = "
    #chart { height: 1fr; }
    #toolbar { height: 3; align: center middle; dock: bottom; }
    Button { margin: 0 1; }
  "
)

message("--- Text Plot Demo exited ---")
