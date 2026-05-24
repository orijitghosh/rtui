#' Create a text-based plot widget
#'
#' Renders charts directly in the terminal using plotext via textual-plotext.
#' The widget displays an empty plot area at creation time. Use the `plot_*()`
#' family of functions to draw data from callbacks.
#'
#' Available chart types: [plot_bar()], [plot_line()], [plot_scatter()],
#' [plot_hist()], [plot_box()], [plot_stacked_bar()], [plot_multiple_bar()],
#' [plot_heatmap()], [plot_candlestick()], [plot_error()], [plot_event()].
#'
#' @param id Optional widget id (required if you want to update the plot later).
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#' @export
text_plot <- function(id = NULL, classes = NULL) {
  validate_id(id)
  validate_classes(classes)
  new_spec("text_plot", id = id, classes = classes,
           props = list())
}

# -- Internal helper to validate app and get py_app ---
.get_py_plot_app <- function(app) {
  if (!inherits(app, "RtuiApp")) abort_spec("`app` must be an RtuiApp object.")
  py_app <- app$.__enclos_env__$private$.py_app
  if (is.null(py_app)) abort_python("App is not running.")
  py_app
}

#' Draw a bar chart on a plot widget
#'
#' @param app An `RtuiApp` object.
#' @param id Widget id of a `text_plot`.
#' @param labels Character vector of bar labels.
#' @param values Numeric vector of bar values.
#' @param title Optional chart title.
#' @param color Optional bar colour (e.g. `"red"`, `"blue"`, `"green"`).
#' @param orientation `"vertical"` (default) or `"horizontal"`.
#' @param xlabel Optional x-axis label.
#' @param ylabel Optional y-axis label.
#' @param clear Whether to clear existing plot data first (default TRUE).
#' @return Invisible `app`.
#' @export
plot_bar <- function(app, id, labels, values, title = NULL, color = NULL,
                     orientation = c("vertical", "horizontal"),
                     xlabel = NULL, ylabel = NULL, clear = TRUE) {
  orientation <- rlang::arg_match(orientation)
  py_app <- .get_py_plot_app(app)
  py_app$draw_plot(id, list(
    type = "bar", labels = as.character(labels), values = as.numeric(values),
    title = title, color = color, orientation = orientation,
    xlabel = xlabel, ylabel = ylabel, clear = clear
  ))
  invisible(app)
}

#' Draw a line plot on a plot widget
#'
#' @param app An `RtuiApp` object.
#' @param id Widget id of a `text_plot`.
#' @param x Numeric vector of x values.
#' @param y Numeric vector of y values.
#' @param title Optional chart title.
#' @param color Optional line colour.
#' @param marker Optional marker character (e.g. `"braille"`, `"dot"`, `"hd"`).
#' @param xlabel Optional x-axis label.
#' @param ylabel Optional y-axis label.
#' @param clear Whether to clear existing plot data first (default TRUE).
#' @return Invisible `app`.
#' @export
plot_line <- function(app, id, x, y, title = NULL, color = NULL,
                      marker = NULL, xlabel = NULL, ylabel = NULL,
                      clear = TRUE) {
  py_app <- .get_py_plot_app(app)
  py_app$draw_plot(id, list(
    type = "line", x = as.numeric(x), y = as.numeric(y),
    title = title, color = color, marker = marker,
    xlabel = xlabel, ylabel = ylabel, clear = clear
  ))
  invisible(app)
}

#' Draw a scatter plot on a plot widget
#'
#' @param app An `RtuiApp` object.
#' @param id Widget id of a `text_plot`.
#' @param x Numeric vector of x values.
#' @param y Numeric vector of y values.
#' @param title Optional chart title.
#' @param color Optional point colour.
#' @param marker Optional marker character.
#' @param xlabel Optional x-axis label.
#' @param ylabel Optional y-axis label.
#' @param clear Whether to clear existing plot data first (default TRUE).
#' @return Invisible `app`.
#' @export
plot_scatter <- function(app, id, x, y, title = NULL, color = NULL,
                         marker = NULL, xlabel = NULL, ylabel = NULL,
                         clear = TRUE) {
  py_app <- .get_py_plot_app(app)
  py_app$draw_plot(id, list(
    type = "scatter", x = as.numeric(x), y = as.numeric(y),
    title = title, color = color, marker = marker,
    xlabel = xlabel, ylabel = ylabel, clear = clear
  ))
  invisible(app)
}

#' Draw a histogram on a plot widget
#'
#' @param app An `RtuiApp` object.
#' @param id Widget id of a `text_plot`.
#' @param data Numeric vector of data values.
#' @param bins Number of bins (default 10).
#' @param title Optional chart title.
#' @param color Optional bar colour.
#' @param xlabel Optional x-axis label.
#' @param ylabel Optional y-axis label.
#' @param clear Whether to clear existing plot data first (default TRUE).
#' @return Invisible `app`.
#' @export
plot_hist <- function(app, id, data, bins = 10L, title = NULL, color = NULL,
                      xlabel = NULL, ylabel = NULL, clear = TRUE) {
  py_app <- .get_py_plot_app(app)
  py_app$draw_plot(id, list(
    type = "hist", data = as.numeric(data), bins = as.integer(bins),
    title = title, color = color,
    xlabel = xlabel, ylabel = ylabel, clear = clear
  ))
  invisible(app)
}

#' Draw a box plot on a plot widget
#'
#' @param app An `RtuiApp` object.
#' @param id Widget id of a `text_plot`.
#' @param data A list of numeric vectors, one per group. E.g.
#'   `list(grpA = rnorm(50), grpB = rnorm(50))`.
#' @param title Optional chart title.
#' @param colors Optional character vector of colours, one per group.
#' @param orientation `"vertical"` (default) or `"horizontal"`.
#' @param xlabel Optional x-axis label.
#' @param ylabel Optional y-axis label.
#' @param clear Whether to clear existing plot data first (default TRUE).
#' @return Invisible `app`.
#' @export
plot_box <- function(app, id, data, title = NULL, colors = NULL,
                     orientation = c("vertical", "horizontal"),
                     xlabel = NULL, ylabel = NULL, clear = TRUE) {
  orientation <- rlang::arg_match(orientation)
  if (!is.list(data)) abort_spec("`data` must be a list of numeric vectors.")
  py_app <- .get_py_plot_app(app)
  # Convert each group to numeric
  plot_data <- lapply(data, as.numeric)
  labels <- if (!is.null(names(data))) names(data) else NULL
  py_app$draw_plot(id, list(
    type = "box", data = plot_data, labels = labels,
    title = title, colors = colors, orientation = orientation,
    xlabel = xlabel, ylabel = ylabel, clear = clear
  ))
  invisible(app)
}

#' Draw a stacked bar chart on a plot widget
#'
#' Multiple data series are stacked on top of each other.
#'
#' @param app An `RtuiApp` object.
#' @param id Widget id of a `text_plot`.
#' @param labels Character vector of bar labels (x-axis categories).
#' @param data A list of named numeric vectors, one per series. Names become
#'   legend labels. E.g. `list(Q1 = c(10, 20), Q2 = c(15, 25))`.
#' @param title Optional chart title.
#' @param colors Optional character vector of colours, one per series.
#' @param orientation `"vertical"` (default) or `"horizontal"`.
#' @param xlabel Optional x-axis label.
#' @param ylabel Optional y-axis label.
#' @param clear Whether to clear existing plot data first (default TRUE).
#' @return Invisible `app`.
#' @export
plot_stacked_bar <- function(app, id, labels, data, title = NULL, colors = NULL,
                             orientation = c("vertical", "horizontal"),
                             xlabel = NULL, ylabel = NULL, clear = TRUE) {
  orientation <- rlang::arg_match(orientation)
  if (!is.list(data)) abort_spec("`data` must be a list of numeric vectors.")
  py_app <- .get_py_plot_app(app)
  series <- lapply(data, as.numeric)
  series_labels <- if (!is.null(names(data))) names(data) else NULL
  py_app$draw_plot(id, list(
    type = "stacked_bar", labels = as.character(labels),
    series = series, series_labels = series_labels,
    title = title, colors = colors, orientation = orientation,
    xlabel = xlabel, ylabel = ylabel, clear = clear
  ))
  invisible(app)
}

#' Draw a grouped (multiple) bar chart on a plot widget
#'
#' Multiple data series are shown side-by-side.
#'
#' @inheritParams plot_stacked_bar
#' @return Invisible `app`.
#' @export
plot_multiple_bar <- function(app, id, labels, data, title = NULL, colors = NULL,
                              orientation = c("vertical", "horizontal"),
                              xlabel = NULL, ylabel = NULL, clear = TRUE) {
  orientation <- rlang::arg_match(orientation)
  if (!is.list(data)) abort_spec("`data` must be a list of numeric vectors.")
  py_app <- .get_py_plot_app(app)
  series <- lapply(data, as.numeric)
  series_labels <- if (!is.null(names(data))) names(data) else NULL
  py_app$draw_plot(id, list(
    type = "multiple_bar", labels = as.character(labels),
    series = series, series_labels = series_labels,
    title = title, colors = colors, orientation = orientation,
    xlabel = xlabel, ylabel = ylabel, clear = clear
  ))
  invisible(app)
}

#' Draw a heatmap on a plot widget
#'
#' @param app An `RtuiApp` object.
#' @param id Widget id of a `text_plot`.
#' @param matrix A numeric matrix or data.frame of values.
#' @param title Optional chart title.
#' @param color Optional colour scheme.
#' @param xlabel Optional x-axis label.
#' @param ylabel Optional y-axis label.
#' @param clear Whether to clear existing plot data first (default TRUE).
#' @return Invisible `app`.
#' @export
plot_heatmap <- function(app, id, matrix, title = NULL, color = NULL,
                         xlabel = NULL, ylabel = NULL, clear = TRUE) {
  py_app <- .get_py_plot_app(app)
  if (is.data.frame(matrix)) matrix <- as.matrix(matrix)
  if (!is.matrix(matrix)) abort_spec("`matrix` must be a matrix or data.frame.")
  # Convert matrix to list-of-lists for Python
  mat_list <- lapply(seq_len(nrow(matrix)), function(i) as.numeric(matrix[i, ]))
  py_app$draw_plot(id, list(
    type = "heatmap", matrix = mat_list,
    title = title, color = color,
    xlabel = xlabel, ylabel = ylabel, clear = clear
  ))
  invisible(app)
}

#' Draw a candlestick chart on a plot widget
#'
#' @param app An `RtuiApp` object.
#' @param id Widget id of a `text_plot`.
#' @param dates Character vector of date labels.
#' @param data A list with components `open`, `close`, `high`, `low` —
#'   each a numeric vector of the same length.
#' @param title Optional chart title.
#' @param colors Optional character vector of two colours: up and down.
#' @param xlabel Optional x-axis label.
#' @param ylabel Optional y-axis label.
#' @param clear Whether to clear existing plot data first (default TRUE).
#' @return Invisible `app`.
#' @export
plot_candlestick <- function(app, id, dates, data, title = NULL, colors = NULL,
                             xlabel = NULL, ylabel = NULL, clear = TRUE) {
  py_app <- .get_py_plot_app(app)
  if (!is.list(data) || !all(c("open", "close", "high", "low") %in% names(data))) {
    abort_spec("`data` must be a list with open, close, high, low components.")
  }
  py_app$draw_plot(id, list(
    type = "candlestick", dates = as.character(dates),
    open = as.numeric(data$open), close = as.numeric(data$close),
    high = as.numeric(data$high), low = as.numeric(data$low),
    title = title, colors = colors,
    xlabel = xlabel, ylabel = ylabel, clear = clear
  ))
  invisible(app)
}

#' Draw error bars on a plot widget
#'
#' @param app An `RtuiApp` object.
#' @param id Widget id of a `text_plot`.
#' @param x Numeric vector of x values.
#' @param y Numeric vector of y values.
#' @param xerr Optional numeric vector of x error bar sizes.
#' @param yerr Optional numeric vector of y error bar sizes.
#' @param title Optional chart title.
#' @param color Optional colour.
#' @param xlabel Optional x-axis label.
#' @param ylabel Optional y-axis label.
#' @param clear Whether to clear existing plot data first (default TRUE).
#' @return Invisible `app`.
#' @export
plot_error <- function(app, id, x, y, xerr = NULL, yerr = NULL,
                       title = NULL, color = NULL,
                       xlabel = NULL, ylabel = NULL, clear = TRUE) {
  py_app <- .get_py_plot_app(app)
  spec <- list(
    type = "error", x = as.numeric(x), y = as.numeric(y),
    title = title, color = color,
    xlabel = xlabel, ylabel = ylabel, clear = clear
  )
  if (!is.null(xerr)) spec$xerr <- as.numeric(xerr)
  if (!is.null(yerr)) spec$yerr <- as.numeric(yerr)
  py_app$draw_plot(id, spec)
  invisible(app)
}

#' Draw an event plot on a plot widget
#'
#' Draws vertical (or horizontal) lines at given positions — useful
#' for marking events along a timeline.
#'
#' @param app An `RtuiApp` object.
#' @param id Widget id of a `text_plot`.
#' @param positions Numeric vector of positions to mark.
#' @param title Optional chart title.
#' @param color Optional colour.
#' @param orientation `"vertical"` (default) or `"horizontal"`.
#' @param xlabel Optional x-axis label.
#' @param ylabel Optional y-axis label.
#' @param clear Whether to clear existing plot data first (default TRUE).
#' @return Invisible `app`.
#' @export
plot_event <- function(app, id, positions, title = NULL, color = NULL,
                       orientation = c("vertical", "horizontal"),
                       xlabel = NULL, ylabel = NULL, clear = TRUE) {
  orientation <- rlang::arg_match(orientation)
  py_app <- .get_py_plot_app(app)
  py_app$draw_plot(id, list(
    type = "event", positions = as.numeric(positions),
    title = title, color = color, orientation = orientation,
    xlabel = xlabel, ylabel = ylabel, clear = clear
  ))
  invisible(app)
}


#' Render a ggplot2 object on a text_plot widget
#'
#' Extracts data and geom layers from a ggplot2 object and renders them
#' as terminal charts using plotext. Supports common geom types:
#' `geom_point`, `geom_line`, `geom_col`/`geom_bar`, `geom_histogram`,
#' `geom_boxplot`, and `geom_smooth`.
#'
#' @param app An `RtuiApp` object.
#' @param id Widget id of a `text_plot`.
#' @param gg A ggplot2 object.
#' @param color Optional default colour override.
#' @param clear Whether to clear existing plot data first (default TRUE).
#' @return Invisible `app`.
#' @export
plot_ggplot <- function(app, id, gg, color = NULL, clear = TRUE) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    abort_spec("ggplot2 is required for plot_ggplot(). Install it with install.packages('ggplot2').")
  }
  if (!inherits(gg, "ggplot")) {
    abort_spec("`gg` must be a ggplot2 object.")
  }
  py_app <- .get_py_plot_app(app)


  # Build the plot to resolve computed data and aesthetics
  built <- ggplot2::ggplot_build(gg)
  plot_data <- built$data
  plot_layout <- built$layout

  # Extract labels
  labels <- gg$labels
  title  <- labels$title
  xlabel <- labels$x
  ylabel <- labels$y

  # Clear if requested (only once, before drawing layers)
  if (clear) {
    py_app$draw_plot(id, list(
      type = "bar", labels = list(), values = list(),
      title = title, xlabel = xlabel, ylabel = ylabel, clear = TRUE
    ))
  }

  # Map each layer
  colors_used <- c("blue", "red", "green", "magenta", "cyan", "yellow")
  for (i in seq_along(gg$layers)) {
    layer <- gg$layers[[i]]
    geom_class <- class(layer$geom)[1]
    d <- as.data.frame(plot_data[[i]])
    layer_color <- color %||% colors_used[((i - 1L) %% length(colors_used)) + 1L]

    if (geom_class %in% c("GeomPoint", "GeomJitter")) {
      # Scatter plot
      if ("x" %in% names(d) && "y" %in% names(d)) {
        py_app$draw_plot(id, list(
          type = "scatter", x = as.numeric(d$x), y = as.numeric(d$y),
          color = layer_color, clear = FALSE,
          title = title, xlabel = xlabel, ylabel = ylabel
        ))
      }

    } else if (geom_class %in% c("GeomLine", "GeomPath", "GeomSmooth",
                                   "GeomStep")) {
      # Line plot
      if ("x" %in% names(d) && "y" %in% names(d)) {
        # Sort by x for lines
        ord <- order(d$x)
        py_app$draw_plot(id, list(
          type = "line", x = as.numeric(d$x[ord]), y = as.numeric(d$y[ord]),
          color = layer_color, marker = "braille", clear = FALSE,
          title = title, xlabel = xlabel, ylabel = ylabel
        ))
      }

    } else if (geom_class %in% c("GeomCol", "GeomBar")) {
      # Bar chart
      if ("x" %in% names(d) && "y" %in% names(d)) {
        x_vals <- d$x
        y_vals <- as.numeric(d$y)
        # Try to use original factor labels from the plot
        x_labels <- if (is.numeric(x_vals)) {
          as.character(round(x_vals, 2))
        } else {
          as.character(x_vals)
        }
        py_app$draw_plot(id, list(
          type = "bar", labels = x_labels, values = y_vals,
          color = layer_color, clear = FALSE,
          title = title, xlabel = xlabel, ylabel = ylabel
        ))
      }

    } else if (geom_class == "GeomHistogram" || geom_class == "GeomFreqpoly") {
      # Histogram — ggplot_build already computed bins
      if ("x" %in% names(d) && "count" %in% names(d)) {
        py_app$draw_plot(id, list(
          type = "bar",
          labels = as.character(round(as.numeric(d$x), 1)),
          values = as.numeric(d$count),
          color = layer_color, clear = FALSE,
          title = title, xlabel = xlabel, ylabel = ylabel %||% "count"
        ))
      } else if ("xmin" %in% names(d) && "xmax" %in% names(d)) {
        mids <- (as.numeric(d$xmin) + as.numeric(d$xmax)) / 2
        counts <- as.numeric(d$count)
        py_app$draw_plot(id, list(
          type = "bar",
          labels = as.character(round(mids, 1)),
          values = counts,
          color = layer_color, clear = FALSE,
          title = title, xlabel = xlabel, ylabel = ylabel %||% "count"
        ))
      }

    } else if (geom_class == "GeomBoxplot") {
      # Box plot — built data has ymin, lower, middle, upper, ymax per group
      if (all(c("ymin", "lower", "middle", "upper", "ymax") %in% names(d))) {
        # Reconstruct approximate data from the five-number summary
        groups <- list()
        group_labels <- c()
        for (j in seq_len(nrow(d))) {
          vals <- c(d$ymin[j], d$lower[j], d$middle[j], d$upper[j], d$ymax[j])
          # Expand to approximate the distribution
          approx_data <- c(
            rep(d$ymin[j], 2), rep(d$lower[j], 5),
            rep(d$middle[j], 6), rep(d$upper[j], 5),
            rep(d$ymax[j], 2)
          )
          groups[[j]] <- as.numeric(approx_data)
          group_labels <- c(group_labels,
            if ("x" %in% names(d)) as.character(d$x[j]) else paste("G", j))
        }
        py_app$draw_plot(id, list(
          type = "box", data = groups, labels = group_labels,
          clear = FALSE,
          title = title, xlabel = xlabel, ylabel = ylabel
        ))
      }

    } else if (geom_class == "GeomAbline" || geom_class == "GeomHline" ||
               geom_class == "GeomVline") {
      # Reference lines — skip (not easily mapped to plotext)
      next

    } else {
      # Fallback: try scatter if x and y exist
      if ("x" %in% names(d) && "y" %in% names(d)) {
        py_app$draw_plot(id, list(
          type = "scatter", x = as.numeric(d$x), y = as.numeric(d$y),
          color = layer_color, clear = FALSE,
          title = title, xlabel = xlabel, ylabel = ylabel
        ))
      }
    }
  }

  invisible(app)
}
