# Example 06: Contact Form
#
# Demonstrates: tui_form(), input, select, checkbox, switch_input,
#               form submission, notifications, confirm dialog.
#
# Run:
#   Rscript inst/examples/06-form.R

library(rtui)

quick_app(
  title = "Contact Form",
  dark = TRUE,

  layout = vstack(
    header(),

    box(
      tui_form(
        Name = input(placeholder = "Your full name"),
        Email = input(placeholder = "you@example.com"),
        Department = select(c("Engineering", "Marketing", "Sales", "Support")),
        Priority = select(c("Low", "Medium", "High")),
        `Subscribe to updates` = checkbox("Yes, send me updates"),
        id = "contact_form"
      ),
      border = "round",
      title = "New Contact",
      id = "form_box"
    ),

    static("Fill out the form and click Submit.", id = "status"),
    footer(),
    id = "root"
  ),

  on_click = list(
    `__form_submit` = function(event, state) {
      vals <- state$get(".form_values", list())
      name <- vals$name %||% ""
      email <- vals$email %||% ""
      if (!nzchar(name)) {
        notify(state$app, "Name is required.", severity = "warning")
        return(state)
      }
      state$set("pending_submit", TRUE)
      confirm(state$app,
              sprintf("Submit contact for %s (%s)?", name, email),
              title = "Confirm Submission")
      state
    }
  ),

  on_screen_result = function(event, state) {
    if (isTRUE(state$get("pending_submit"))) {
      state$set("pending_submit", FALSE)
      if (isTRUE(event$value)) {
        vals <- state$get(".form_values", list())
        update(state$app, "status",
               content = sprintf("Submitted: %s (%s) - %s priority",
                                 vals$name %||% "?",
                                 vals$email %||% "?",
                                 vals$priority %||% "?"))
        notify(state$app, "Contact submitted!", severity = "info")
      } else {
        update(state$app, "status", content = "Submission cancelled.")
      }
    }
    state
  },

  bindings = list(
    binding("q", "quit_app", "Quit", priority = TRUE),
    binding("escape", "quit_app", "Quit", priority = TRUE)
  ),
  on_action = function(event, state) {
    if (event$value == "quit_app") return(quit(state))
    state
  },

  css = "
    #form_box { margin: 1 4; height: auto; max-width: 70; }
    #status { height: 1; dock: bottom; padding: 0 1; }
  "
)
