# Example 08: Tabbed Dashboard
#
# Demonstrates: tabs, tab_pane, content_switcher, data_table,
#               sparkline, static with markup, charts, themes.
#
# Run:
#   Rscript inst/examples/08-tabs-dashboard.R

library(rtui)

# Sample data
sales <- data.frame(
  Month = month.abb,
  Revenue = c(12, 15, 18, 22, 19, 25, 28, 30, 27, 32, 35, 38) * 1000,
  Units = c(120, 145, 170, 210, 185, 240, 270, 295, 260, 310, 340, 365)
)

quick_app(
  title = "Sales Dashboard",
  dark = TRUE,

  layout = vstack(
    header(),

    tabs(
      tab_pane(
        "Overview",
        vstack(
          hstack(
            box(
              static("[bold]Total Revenue[/bold]", id = "rev_label"),
              digits(format(sum(sales$Revenue), big.mark = ","),
                     id = "total_revenue"),
              border = "round", id = "rev_card"
            ),
            box(
              static("[bold]Total Units[/bold]", id = "unit_label"),
              digits(format(sum(sales$Units), big.mark = ","),
                     id = "total_units"),
              border = "round", id = "unit_card"
            ),
            box(
              static("[bold]Avg Revenue[/bold]", id = "avg_label"),
              digits(format(round(mean(sales$Revenue)), big.mark = ","),
                     id = "avg_revenue"),
              border = "round", id = "avg_card"
            ),
            id = "kpi_row"
          ),
          hstack(
            box(
              sparkline(sales$Revenue, id = "rev_spark"),
              border = "round", title = "Revenue Trend"
            ),
            box(
              sparkline(sales$Units, id = "unit_spark"),
              border = "round", title = "Units Trend"
            ),
            id = "spark_row"
          ),
          id = "overview_panel"
        ),
        id = "tab_overview"
      ),

      tab_pane(
        "Data",
        data_table(sales, id = "sales_table",
                   sortable = TRUE, zebra_stripes = TRUE),
        id = "tab_data"
      ),

      tab_pane(
        "Chart",
        box(
          plot_bar(
            labels = sales$Month,
            values = sales$Revenue / 1000,
            title = "Monthly Revenue ($K)",
            id = "rev_chart"
          ),
          border = "round",
          id = "chart_box"
        ),
        id = "tab_chart"
      ),

      id = "main_tabs"
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
    tui_theme("catppuccin"),
    "
    #main_tabs { height: 1fr; }
    #kpi_row { height: 8; }
    #rev_card, #unit_card, #avg_card { width: 1fr; }
    Digits { text-align: center; }
    #spark_row { height: 8; }
    #sales_table { height: 1fr; }
    #chart_box { height: 1fr; margin: 1; }
    #overview_panel { height: 1fr; padding: 1; }
    "
  )
)
