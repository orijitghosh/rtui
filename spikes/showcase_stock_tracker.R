# Showcase: Live Stock Market Dashboard
#
# Pulls real stock data via yfinance, displays price charts,
# candlestick, volume, and a data table — all in the terminal.
#
# Run from a REAL TERMINAL:
#   & "C:\Program Files\R\R-4.4.3\bin\Rscript.exe" spikes/showcase_stock_tracker.R

Sys.unsetenv("RETICULATE_PYTHON")
Sys.setenv(RETICULATE_PYTHON_ENV = "r-rtui")

library(reticulate)
use_virtualenv("r-rtui", required = TRUE)

devtools::load_all(".")

message("--- Stock Market Dashboard ---")
message("Type a ticker, pick a time range, and click Load.")
message("Press q/Escape to quit.")

# --- Helper: fetch stock data via yfinance (through reticulate) ---
fetch_stock <- function(ticker, period = "1mo") {
  py_run_string(sprintf("
import yfinance as yf
_t = yf.Ticker('%s')
_h = _t.history(period='%s')
_h = _h.reset_index()
_h['Date'] = _h['Date'].dt.strftime('%%Y-%%m-%%d')
", ticker, period))
  df <- py$`_h`
  if (is.null(df) || nrow(df) == 0) return(NULL)
  # Ensure numeric columns
  df$Open  <- as.numeric(df$Open)
  df$High  <- as.numeric(df$High)
  df$Low   <- as.numeric(df$Low)
  df$Close <- as.numeric(df$Close)
  df$Volume <- as.numeric(df$Volume)
  df$Date  <- as.character(df$Date)
  df
}

# --- Helper: draw the selected chart type ---
draw_chart <- function(app, df, ticker, chart_type) {
  if (is.null(df) || nrow(df) == 0) {
    notify(app, "No data to plot", severity = "warning")
    return()
  }

  n <- nrow(df)
  dates <- df$Date

  if (chart_type == "line") {
    plot_line(app, "chart",
              x = seq_len(n), y = df$Close,
              title = paste(ticker, "- Close Price"),
              color = "green", marker = "braille",
              xlabel = paste(dates[1], "to", dates[n]),
              ylabel = "Price ($)")

  } else if (chart_type == "candle") {
    plot_candlestick(app, "chart",
                     dates = dates,
                     data = list(open = df$Open, close = df$Close,
                                 high = df$High, low = df$Low),
                     title = paste(ticker, "- Candlestick"),
                     colors = c("green", "red"))

  } else if (chart_type == "volume") {
    plot_bar(app, "chart",
             labels = dates, values = df$Volume / 1e6,
             title = paste(ticker, "- Volume (millions)"),
             color = "cyan",
             ylabel = "Volume (M)")

  } else if (chart_type == "scatter") {
    # Price vs Volume scatter
    plot_scatter(app, "chart",
                 x = df$Volume / 1e6, y = df$Close,
                 title = paste(ticker, "- Price vs Volume"),
                 color = "magenta",
                 xlabel = "Volume (M)", ylabel = "Close ($)")
  }
}

# --- Helper: populate table + status after loading ---
show_stock_data <- function(app, df, ticker) {
  # Summary
  chg <- round(df$Close[nrow(df)] - df$Close[1], 2)
  pct <- round(chg / df$Close[1] * 100, 2)
  arrow <- if (chg >= 0) "+" else ""
  update(app, "status_bar",
         content = paste0(ticker, " | ", nrow(df), " days | $",
                          round(df$Close[nrow(df)], 2),
                          " (", arrow, chg, " / ", arrow, pct, "%)"))

  # Update table
  display_df <- data.frame(
    Date   = df$Date,
    Open   = round(df$Open, 2),
    High   = round(df$High, 2),
    Low    = round(df$Low, 2),
    Close  = round(df$Close, 2),
    Volume = round(df$Volume / 1e6, 1)
  )
  update(app, "price_table", clear_data = TRUE)
  update(app, "price_table", add_rows = as.list(display_df))
}

# --- Build the app ---
quick_app(
  title = "Stock Dashboard",
  dark = TRUE,

  layout = vstack(
    header(),

    # Controls bar
    hstack(
      static("Ticker:", id = "lbl_ticker"),
      input(placeholder = "e.g. AAPL, MSFT, GOOGL", value = "AAPL", id = "ticker_input"),
      static("Period:", id = "lbl_period"),
      select(c("5d", "1mo", "3mo", "6mo", "1y", "2y"), value = "1mo",
             prompt = "Range", id = "period_sel"),
      button("Load", id = "load_btn"),
      id = "controls"
    ),

    # Loading indicator (shown during data fetch, hidden when done)
    loading(id = "loader"),

    # Chart tabs
    tabs(
      tab_pane(
        text_plot(id = "chart"),
        title = "Chart", id = "tab_chart"
      ),
      tab_pane(
        data_table(
          data.frame(Date = character(0), Open = numeric(0), High = numeric(0),
                     Low = numeric(0), Close = numeric(0), Volume = numeric(0)),
          id = "price_table", cursor = "row", zebra_stripes = TRUE, sortable = TRUE
        ),
        title = "Data", id = "tab_data"
      ),
      id = "main_tabs"
    ),

    # Chart type selector
    hstack(
      button("Line", id = "btn_line"),
      button("Candle", id = "btn_candle"),
      button("Volume", id = "btn_volume"),
      button("Scatter", id = "btn_scatter"),
      id = "chart_toolbar"
    ),

    # Status bar
    static("Loading AAPL data...", id = "status_bar"),

    footer(),
    id = "root"
  ),

  on_mount = function(event, state) {
    state$set("chart_type", "line")
    # Show loader, hide chart content until data arrives
    update(state$app, "loader", display = TRUE)
    update(state$app, "main_tabs", display = FALSE)
    update(state$app, "chart_toolbar", display = FALSE)
    # Defer the actual data fetch so the UI paints first
    set_timer(state$app, 0.1, "initial_load")
    state
  },

  on_timer = function(event, state) {
    if (event$timer_id == "initial_load") {
      tryCatch({
        df <- fetch_stock("AAPL", "1mo")
        if (!is.null(df)) {
          state$set(".stock_data", df)
          state$set(".ticker", "AAPL")
          draw_chart(state$app, df, "AAPL", "line")
          show_stock_data(state$app, df, "AAPL")
        } else {
          update(state$app, "status_bar", content = "No data for AAPL")
        }
      }, error = function(e) {
        notify(state$app, paste("Load error:", conditionMessage(e)), severity = "error")
        update(state$app, "status_bar", content = "Error loading AAPL")
      })
      # Hide loader, show chart content
      update(state$app, "loader", display = FALSE)
      update(state$app, "main_tabs", display = TRUE)
      update(state$app, "chart_toolbar", display = TRUE)
    }
    state
  },

  on_click = list(
    # Load button
    load_btn = function(event, state) {
      ticker <- collect_form(state$app, "ticker_input")$ticker_input
      period <- collect_form(state$app, "period_sel")$period_sel
      if (is.null(ticker) || nchar(ticker) == 0) ticker <- "AAPL"
      if (is.null(period)) period <- "1mo"
      ticker <- toupper(trimws(ticker))

      update(state$app, "status_bar",
             content = paste0("Loading ", ticker, " (", period, ")..."))
      # Show loader while fetching
      update(state$app, "loader", display = TRUE)

      tryCatch({
        df <- fetch_stock(ticker, period)
        if (is.null(df) || nrow(df) == 0) {
          notify(state$app, paste0("No data for '", ticker, "'"), severity = "error")
          update(state$app, "status_bar", content = paste0("No data for ", ticker))
          update(state$app, "loader", display = FALSE)
          return(state)
        }
        state$set(".stock_data", df)
        state$set(".ticker", ticker)

        chart_type <- state$get("chart_type", "line")
        draw_chart(state$app, df, ticker, chart_type)
        show_stock_data(state$app, df, ticker)

      }, error = function(e) {
        notify(state$app, paste("Error:", conditionMessage(e)), severity = "error")
        update(state$app, "status_bar", content = paste0("Error loading ", ticker))
      })
      # Hide loader
      update(state$app, "loader", display = FALSE)
      state
    },

    # Chart type buttons
    btn_line = function(event, state) {
      state$set("chart_type", "line")
      df <- state$get(".stock_data")
      ticker <- state$get(".ticker", "")
      draw_chart(state$app, df, ticker, "line")
      state
    },
    btn_candle = function(event, state) {
      state$set("chart_type", "candle")
      df <- state$get(".stock_data")
      ticker <- state$get(".ticker", "")
      draw_chart(state$app, df, ticker, "candle")
      state
    },
    btn_volume = function(event, state) {
      state$set("chart_type", "volume")
      df <- state$get(".stock_data")
      ticker <- state$get(".ticker", "")
      draw_chart(state$app, df, ticker, "volume")
      state
    },
    btn_scatter = function(event, state) {
      state$set("chart_type", "scatter")
      df <- state$get(".stock_data")
      ticker <- state$get(".ticker", "")
      draw_chart(state$app, df, ticker, "scatter")
      state
    }
  ),

  on_submit = list(
    # Enter key in ticker input = same as clicking Load
    ticker_input = function(event, state) {
      ticker <- event$value
      if (is.null(ticker) || nchar(ticker) == 0) return(state)
      ticker <- toupper(trimws(ticker))

      update(state$app, "status_bar",
             content = paste0("Loading ", ticker, "..."))
      update(state$app, "loader", display = TRUE)

      period <- collect_form(state$app, "period_sel")$period_sel
      if (is.null(period)) period <- "1mo"

      tryCatch({
        df <- fetch_stock(ticker, period)
        if (is.null(df) || nrow(df) == 0) {
          notify(state$app, paste0("No data for '", ticker, "'"), severity = "error")
          update(state$app, "loader", display = FALSE)
          return(state)
        }
        state$set(".stock_data", df)
        state$set(".ticker", ticker)
        chart_type <- state$get("chart_type", "line")
        draw_chart(state$app, df, ticker, chart_type)
        show_stock_data(state$app, df, ticker)
      }, error = function(e) {
        notify(state$app, paste("Error:", conditionMessage(e)), severity = "error")
      })
      update(state$app, "loader", display = FALSE)
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
    tui_theme("ocean"),
    "
    #controls { height: 3; align: left middle; padding: 0 1; }
    #lbl_ticker, #lbl_period { width: auto; padding: 0 1; }
    #ticker_input { width: 25; }
    #period_sel { width: 15; }
    #load_btn { margin: 0 1; }
    #loader { height: auto; }
    #chart { height: 1fr; }
    #chart_toolbar { height: 3; align: center middle; }
    #status_bar { height: 1; dock: bottom; background: #112240;
                  color: #64ffda; padding: 0 1; }
    Button { margin: 0 1; }
    DataTable { height: 1fr; }
    "
  )
)

message("--- Stock Dashboard exited ---")
