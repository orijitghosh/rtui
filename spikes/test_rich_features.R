# Showcase: Rich DataTable + Forms + Confirmation Dialogs
#
# All three features visible on one screen — no tabs hiding anything.
#
# Run from a REAL TERMINAL:
#   & "C:\Program Files\R\R-4.4.3\bin\Rscript.exe" spikes/test_rich_features.R

Sys.unsetenv("RETICULATE_PYTHON")
Sys.setenv(RETICULATE_PYTHON_ENV = "r-rtui")

library(reticulate)
use_virtualenv("r-rtui", required = TRUE)

devtools::load_all(".")

# --- Sample data ---
employees <- data.frame(
  Name   = c("Alice", "Bob", "Carol", "Dave", "Eve"),
  Dept   = c("Eng", "Mktg", "Eng", "Sales", "Eng"),
  Salary = c(95000, 72000, 105000, 68000, 98000),
  stringsAsFactors = FALSE
)

message("--- Launching Rich Features Demo ---")
message("  - TOP: sortable table (click headers to sort, click row for detail)")
message("  - BOTTOM: form to add employees, with confirmation dialog")
message("  - Press q or Escape to quit")

quick_app(
  title = "Employee Manager",
  dark = TRUE,

  layout = vstack(
    header(),

    # --- Top half: Sortable DataTable ---
    static("[b]Employees[/b] (click headers to sort, Enter on row for details)",
           id = "table_title"),
    data_table(employees, id = "emp_table",
               cursor = "row", zebra_stripes = TRUE, sortable = TRUE),
    static("Select a row...", id = "row_detail"),

    rule("Add New Employee"),

    # --- Bottom half: Form ---
    tui_form(
      Name       = input(placeholder = "Full name"),
      Department = select(c("Engineering", "Marketing", "Sales")),
      Salary     = input(placeholder = "e.g. 80000"),
      submit_label = "Add Employee",
      id = "add_form"
    ),
    static("", id = "form_msg"),

    footer(),
    id = "root"
  ),

  on_click = list(
    # --- Row clicked in table: show detail ---
    emp_table = function(event, state) {
      rd <- event$value$row_data
      if (!is.null(rd)) {
        msg <- paste0("Selected: ", rd$Name, " | ", rd$Dept, " | $", rd$Salary)
        update(state$app, "row_detail", content = msg)
      }
      state
    },

    # --- Form submit button clicked ---
    `__form_submit` = function(event, state) {
      vals <- collect_form(state$app, c("name", "department", "salary"))
      nm <- vals$name
      if (is.null(nm) || nchar(nm) == 0) {
        notify(state$app, "Name is required!", severity = "error")
        return(state)
      }
      # Stash pending data and show confirm dialog
      state$set(".pending", vals)
      confirm(state$app,
              paste0("Add '", nm, "' to the team?"),
              title = "Confirm")
      state
    }
  ),

  # --- Sort feedback ---
  on_change = list(
    emp_table = function(event, state) {
      sc <- event$value$sort_column
      if (!is.null(sc)) {
        dir <- if (isTRUE(event$value$reverse)) "descending" else "ascending"
        update(state$app, "table_title",
               content = paste0("[b]Employees[/b] sorted by ", sc, " (", dir, ")"))
      }
      state
    }
  ),

  # --- Dialog result ---
  on_screen_result = function(event, state) {
    if (isTRUE(event$value)) {
      vals <- state$get(".pending")
      if (!is.null(vals)) {
        dept <- if (is.null(vals$department)) "N/A" else vals$department
        sal  <- if (is.null(vals$salary) || nchar(vals$salary) == 0) "0" else vals$salary
        new_row <- list(
          Name   = list(vals$name),
          Dept   = list(dept),
          Salary = list(sal)
        )
        update(state$app, "emp_table", add_rows = new_row)
        update(state$app, "form_msg",
               content = paste0("Added: ", vals$name, " (", dept, ", $", sal, ")"))
        notify(state$app, paste0("Added ", vals$name, "!"))
      }
    } else {
      update(state$app, "form_msg", content = "Cancelled.")
      notify(state$app, "Cancelled", severity = "warning")
    }
    state$set(".pending", NULL)
    state
  },

  # --- Quit ---
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
    #table_title { height: 1; background: $accent; color: $text; padding: 0 1; }
    #emp_table { height: 8; }
    #row_detail { height: 1; background: $primary; color: $text; padding: 0 1; }
    #add_form { height: auto; padding: 0 1; }
    #form_msg { height: 1; color: $success; padding: 0 1; }
    Rule { margin: 0; }
    Static { width: 100%; }
    Button { margin: 0 1; }
  "
)

message("--- Rich Features Demo exited ---")
