# Showcase: ggplot2 Terminal Explorer
#
# Renders ggplot2 plots directly in the terminal! Pick datasets,
# choose geom types, and see them rendered as text charts.
# Uses the command palette (Ctrl+P) for quick access.
#
# Run from a REAL TERMINAL:
#   & "C:\Program Files\R\R-4.4.3\bin\Rscript.exe" spikes/showcase_ggplot_explorer.R

Sys.unsetenv("RETICULATE_PYTHON")
Sys.setenv(RETICULATE_PYTHON_ENV = "r-rtui")

library(reticulate)
use_virtualenv("r-rtui", required = TRUE)

devtools::load_all(".")

if (!requireNamespace("ggplot2", quietly = TRUE)) {
  stop("This demo requires ggplot2. Install with: install.packages('ggplot2')")
}
library(ggplot2)

message("--- ggplot2 Terminal Explorer ---")
message("Renders ggplot2 objects as terminal charts via plotext.")
message("Press Ctrl+P for command palette, q to quit.")

# --- Pre-built ggplot examples ---
make_scatter <- function() {
  ggplot(mtcars, aes(x = wt, y = mpg)) +
    geom_point() +
    labs(title = "mtcars: Weight vs MPG",
         x = "Weight (1000 lbs)", y = "Miles per Gallon")
}

make_line <- function() {
  df <- data.frame(
    x = 1:50,
    y = cumsum(rnorm(50))
  )
  ggplot(df, aes(x = x, y = y)) +
    geom_line() +
    labs(title = "Random Walk", x = "Step", y = "Value")
}

make_bar <- function() {
  df <- data.frame(
    cyl = factor(c(4, 6, 8)),
    count = as.numeric(table(mtcars$cyl))
  )
  ggplot(df, aes(x = cyl, y = count)) +
    geom_col() +
    labs(title = "mtcars: Cylinders", x = "Cylinders", y = "Count")
}

make_histogram <- function() {
  ggplot(mtcars, aes(x = mpg)) +
    geom_histogram(bins = 12) +
    labs(title = "mtcars: MPG Distribution", x = "MPG", y = "Count")
}

make_boxplot <- function() {
  ggplot(mtcars, aes(x = factor(cyl), y = mpg)) +
    geom_boxplot() +
    labs(title = "mtcars: MPG by Cylinders", x = "Cylinders", y = "MPG")
}

make_smooth <- function() {
  ggplot(mtcars, aes(x = wt, y = mpg)) +
    geom_point() +
    geom_smooth(method = "lm", se = FALSE) +
    labs(title = "mtcars: Weight vs MPG with Trend",
         x = "Weight (1000 lbs)", y = "MPG")
}

make_iris_scatter <- function() {
  ggplot(iris, aes(x = Sepal.Length, y = Petal.Length)) +
    geom_point() +
    labs(title = "Iris: Sepal vs Petal Length",
         x = "Sepal Length", y = "Petal Length")
}

make_multi_layer <- function() {
  df <- data.frame(
    x = 1:30,
    y1 = sin(1:30 * pi / 10) * 10 + 20,
    y2 = cos(1:30 * pi / 10) * 8 + 22
  )
  ggplot(df) +
    geom_line(aes(x = x, y = y1)) +
    geom_line(aes(x = x, y = y2)) +
    labs(title = "Two Sine Waves", x = "X", y = "Y")
}

# Named list of all examples
examples <- list(
  "Scatter: mtcars" = make_scatter,
  "Line: Random Walk" = make_line,
  "Bar: Cylinders" = make_bar,
  "Histogram: MPG" = make_histogram,
  "Box: MPG by Cyl" = make_boxplot,
  "Smooth: Weight+Trend" = make_smooth,
  "Scatter: Iris" = make_iris_scatter,
  "Multi-Layer: Waves" = make_multi_layer
)

# --- Build the app ---
quick_app(
  title = "ggplot2 Explorer",
  dark = TRUE,

  layout = vstack(
    header(),

    # Toolbar
    hstack(
      button("Scatter", id = "btn_scatter"),
      button("Line", id = "btn_line"),
      button("Bar", id = "btn_bar"),
      button("Histogram", id = "btn_hist"),
      button("Box", id = "btn_box"),
      button("Smooth", id = "btn_smooth"),
      button("Iris", id = "btn_iris"),
      button("Multi", id = "btn_multi"),
      id = "toolbar"
    ),

    # Chart area
    text_plot(id = "chart"),

    # Code display
    collapsible(
      "ggplot2 code",
      static("Select a chart type above to see the ggplot2 code.", id = "code_display"),
      collapsed = FALSE, id = "code_section"
    ),

    # Status bar
    static("Select a chart type or press Ctrl+P for command palette.", id = "status_bar"),

    footer(),
    id = "root"
  ),

  on_mount = function(event, state) {
    # Register command palette entries
    register_commands(state$app, list(
      command("Scatter Plot (mtcars)", "plot_scatter",
              help = "Weight vs MPG scatter plot"),
      command("Line Plot (Random Walk)", "plot_line",
              help = "Cumulative random walk"),
      command("Bar Chart (Cylinders)", "plot_bar",
              help = "Cylinder count bar chart"),
      command("Histogram (MPG)", "plot_hist",
              help = "MPG distribution histogram"),
      command("Box Plot (MPG by Cyl)", "plot_box",
              help = "MPG distribution by cylinder count"),
      command("Scatter + Trend Line", "plot_smooth",
              help = "Weight vs MPG with linear fit"),
      command("Iris Scatter", "plot_iris",
              help = "Sepal vs Petal length"),
      command("Multi-Layer (Waves)", "plot_multi",
              help = "Two overlaid sine waves"),
      command("Toggle Dark Mode", "toggle_dark",
              help = "Switch between dark and light theme")
    ))

    # Draw initial chart
    tryCatch({
      gg <- make_scatter()
      plot_ggplot(state$app, "chart", gg)
      update(state$app, "code_display",
             content = 'ggplot(mtcars, aes(x = wt, y = mpg)) + geom_point()')
      update(state$app, "status_bar",
             content = "Scatter: mtcars | ggplot2 -> terminal via plotext")
    }, error = function(e) {
      notify(state$app, paste("Error:", conditionMessage(e)), severity = "error")
    })
    state
  },

  on_click = list(
    btn_scatter = function(event, state) {
      tryCatch({
        plot_ggplot(state$app, "chart", make_scatter())
        update(state$app, "code_display",
               content = 'ggplot(mtcars, aes(x = wt, y = mpg)) + geom_point()')
        update(state$app, "status_bar", content = "Scatter: mtcars wt vs mpg")
      }, error = function(e) notify(state$app, conditionMessage(e), severity = "error"))
      state
    },
    btn_line = function(event, state) {
      tryCatch({
        plot_ggplot(state$app, "chart", make_line(), color = "cyan")
        update(state$app, "code_display",
               content = 'ggplot(df, aes(x, y)) + geom_line()')
        update(state$app, "status_bar", content = "Line: Random Walk")
      }, error = function(e) notify(state$app, conditionMessage(e), severity = "error"))
      state
    },
    btn_bar = function(event, state) {
      tryCatch({
        plot_ggplot(state$app, "chart", make_bar(), color = "green")
        update(state$app, "code_display",
               content = 'ggplot(df, aes(x = cyl, y = count)) + geom_col()')
        update(state$app, "status_bar", content = "Bar: Cylinder counts")
      }, error = function(e) notify(state$app, conditionMessage(e), severity = "error"))
      state
    },
    btn_hist = function(event, state) {
      tryCatch({
        plot_ggplot(state$app, "chart", make_histogram(), color = "yellow")
        update(state$app, "code_display",
               content = 'ggplot(mtcars, aes(x = mpg)) + geom_histogram(bins = 12)')
        update(state$app, "status_bar", content = "Histogram: MPG distribution")
      }, error = function(e) notify(state$app, conditionMessage(e), severity = "error"))
      state
    },
    btn_box = function(event, state) {
      tryCatch({
        plot_ggplot(state$app, "chart", make_boxplot())
        update(state$app, "code_display",
               content = 'ggplot(mtcars, aes(x = factor(cyl), y = mpg)) + geom_boxplot()')
        update(state$app, "status_bar", content = "Box: MPG by Cylinders")
      }, error = function(e) notify(state$app, conditionMessage(e), severity = "error"))
      state
    },
    btn_smooth = function(event, state) {
      tryCatch({
        plot_ggplot(state$app, "chart", make_smooth())
        update(state$app, "code_display",
               content = 'ggplot(mtcars, aes(wt, mpg)) + geom_point() + geom_smooth(method="lm")')
        update(state$app, "status_bar", content = "Smooth: Weight vs MPG + linear trend")
      }, error = function(e) notify(state$app, conditionMessage(e), severity = "error"))
      state
    },
    btn_iris = function(event, state) {
      tryCatch({
        plot_ggplot(state$app, "chart", make_iris_scatter(), color = "magenta")
        update(state$app, "code_display",
               content = 'ggplot(iris, aes(Sepal.Length, Petal.Length)) + geom_point()')
        update(state$app, "status_bar", content = "Iris: Sepal vs Petal length")
      }, error = function(e) notify(state$app, conditionMessage(e), severity = "error"))
      state
    },
    btn_multi = function(event, state) {
      tryCatch({
        plot_ggplot(state$app, "chart", make_multi_layer())
        update(state$app, "code_display",
               content = 'ggplot(df) + geom_line(aes(x, y1)) + geom_line(aes(x, y2))')
        update(state$app, "status_bar", content = "Multi-layer: Two sine waves")
      }, error = function(e) notify(state$app, conditionMessage(e), severity = "error"))
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
    # Command palette actions
    action_map <- list(
      plot_scatter = "btn_scatter",
      plot_line = "btn_line",
      plot_bar = "btn_bar",
      plot_hist = "btn_hist",
      plot_box = "btn_box",
      plot_smooth = "btn_smooth",
      plot_iris = "btn_iris",
      plot_multi = "btn_multi"
    )
    # Simulate button click for command palette actions
    btn_id <- action_map[[event$value]]
    if (!is.null(btn_id)) {
      # Re-use the click handler by dispatching
      handler <- list(
        btn_scatter = function() {
          plot_ggplot(state$app, "chart", make_scatter())
          update(state$app, "status_bar", content = "Scatter: mtcars")
        },
        btn_line = function() {
          plot_ggplot(state$app, "chart", make_line(), color = "cyan")
          update(state$app, "status_bar", content = "Line: Random Walk")
        },
        btn_bar = function() {
          plot_ggplot(state$app, "chart", make_bar(), color = "green")
          update(state$app, "status_bar", content = "Bar: Cylinders")
        },
        btn_hist = function() {
          plot_ggplot(state$app, "chart", make_histogram(), color = "yellow")
          update(state$app, "status_bar", content = "Histogram: MPG")
        },
        btn_box = function() {
          plot_ggplot(state$app, "chart", make_boxplot())
          update(state$app, "status_bar", content = "Box: MPG by Cyl")
        },
        btn_smooth = function() {
          plot_ggplot(state$app, "chart", make_smooth())
          update(state$app, "status_bar", content = "Smooth: Weight+Trend")
        },
        btn_iris = function() {
          plot_ggplot(state$app, "chart", make_iris_scatter(), color = "magenta")
          update(state$app, "status_bar", content = "Iris: Scatter")
        },
        btn_multi = function() {
          plot_ggplot(state$app, "chart", make_multi_layer())
          update(state$app, "status_bar", content = "Multi-layer: Waves")
        }
      )
      tryCatch(
        handler[[btn_id]](),
        error = function(e) notify(state$app, conditionMessage(e), severity = "error")
      )
    }
    state
  },

  css = paste0(
    tui_theme("catppuccin"),
    "
    #toolbar { height: 3; align: center middle; }
    #chart { height: 1fr; }
    #code_section { height: auto; max-height: 6; }
    #code_display { padding: 0 2; color: #a6e3a1; }
    #status_bar { height: 1; dock: bottom; background: #313244;
                  color: #cdd6f4; padding: 0 1; }
    Button { margin: 0 1; min-width: 8; }
    "
  )
)

message("--- ggplot2 Explorer exited ---")
