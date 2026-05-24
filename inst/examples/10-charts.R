# Example 10: Chart Gallery
#
# Demonstrates: plot_bar, plot_line, plot_scatter, plot_hist,
#               plot_box, plot_heatmap, tabs, themes.
#
# Run:
#   Rscript inst/examples/10-charts.R

library(rtui)

# Generate sample data
set.seed(42)
months <- month.abb
revenue <- c(12, 15, 18, 22, 19, 25, 28, 30, 27, 32, 35, 38)
temps <- rnorm(100, mean = 22, sd = 5)
x_scatter <- runif(50, 0, 100)
y_scatter <- 2 * x_scatter + rnorm(50, sd = 15)

quick_app(
  title = "Chart Gallery",
  dark = TRUE,

  layout = vstack(
    header(),

    tabs(
      tab_pane(
        "Bar",
        box(
          plot_bar(labels = months, values = revenue,
                   title = "Monthly Revenue ($K)", id = "bar_chart"),
          border = "round"
        ),
        id = "tab_bar"
      ),

      tab_pane(
        "Line",
        box(
          plot_line(x = seq_along(revenue), y = revenue,
                    title = "Revenue Trend", id = "line_chart"),
          border = "round"
        ),
        id = "tab_line"
      ),

      tab_pane(
        "Scatter",
        box(
          plot_scatter(x = round(x_scatter, 1),
                       y = round(y_scatter, 1),
                       title = "X vs Y Correlation",
                       id = "scatter_chart"),
          border = "round"
        ),
        id = "tab_scatter"
      ),

      tab_pane(
        "Histogram",
        box(
          plot_hist(values = round(temps, 1), bins = 15L,
                    title = "Temperature Distribution",
                    id = "hist_chart"),
          border = "round"
        ),
        id = "tab_hist"
      ),

      tab_pane(
        "Heatmap",
        box(
          plot_heatmap(
            matrix = matrix(round(runif(35, 0, 100)), nrow = 5),
            row_labels = c("Mon", "Tue", "Wed", "Thu", "Fri"),
            col_labels = paste0("W", 1:7),
            title = "Weekly Activity Heatmap",
            id = "heat_chart"
          ),
          border = "round"
        ),
        id = "tab_heat"
      ),

      id = "chart_tabs"
    ),

    footer(),
    id = "root"
  ),

  bindings = list(
    binding("q", "quit_app", "Quit"),
    binding("d", "toggle_dark", "Dark mode")
  ),
  on_action = function(event, state) {
    if (event$value == "quit_app") return(quit(state))
    if (event$value == "toggle_dark") dark_toggle(state$app)
    state
  },

  css = paste0(
    tui_theme("dracula"),
    "
    #chart_tabs { height: 1fr; }
    TabPane { padding: 1; }
    "
  )
)
