# Example 11: Screens & Modals
#
# Demonstrates: push_screen, pop_screen, tui_screen, confirm, alert,
#               modal dialogs, screen results, multi-screen navigation.
#
# Run:
#   Rscript inst/examples/11-screens-modal.R

library(rtui)

# Pre-define the settings screen layout
settings_screen <- tui_screen(
  layout = center(
    middle(
      vstack(
        static("[bold]Settings[/bold]", id = "settings_title"),
        rule(),
        hstack(
          static("Username:", id = "lbl_user"),
          input(value = "admin", id = "username"),
          id = "row_user"
        ),
        hstack(
          static("Theme:", id = "lbl_theme"),
          select(c("Dark", "Light", "Auto"), id = "theme_select"),
          id = "row_theme"
        ),
        hstack(
          static("Notifications:", id = "lbl_notify"),
          switch_input(value = TRUE, id = "notify_switch"),
          id = "row_notify"
        ),
        rule(),
        hstack(
          button("Save", id = "btn_save_settings"),
          button("Cancel", id = "btn_cancel_settings"),
          id = "settings_buttons"
        ),
        id = "settings_panel"
      ),
      id = "settings_mid"
    ),
    id = "settings_center"
  ),
  css = "
    #settings_panel { width: 50; height: auto; border: heavy $accent;
                      padding: 1 2; background: $surface; }
    #settings_title { text-align: center; height: 2; }
    #row_user, #row_theme, #row_notify { height: 3; }
    Static { width: 16; padding: 0 1; }
    Input, Select { width: 1fr; }
    #settings_buttons { height: 3; align: center middle; }
    Button { margin: 0 1; min-width: 10; }
    Rule { height: 1; margin: 0; }
  "
)

quick_app(
  title = "Multi-Screen App",
  dark = TRUE,

  layout = vstack(
    header(),
    center(
      vstack(
        static("[bold]Welcome to the multi-screen demo![/bold]", id = "welcome"),
        rule(),
        static("Current user: admin", id = "user_display"),
        static("Notifications: ON", id = "notify_display"),
        rule(),
        hstack(
          button("Settings", id = "btn_settings"),
          button("About", id = "btn_about"),
          button("Quit", id = "btn_quit"),
          id = "main_buttons"
        ),
        id = "main_panel"
      ),
      id = "main_center"
    ),
    footer(),
    id = "root"
  ),

  on_click = list(
    btn_settings = function(event, state) {
      state$set("awaiting", "settings")
      push_screen(state$app, settings_screen)
      state
    },

    btn_about = function(event, state) {
      alert(state$app,
            "rtui — Build terminal UIs from R.\nVersion 0.1.0",
            title = "About rtui")
      state
    },

    btn_quit = function(event, state) {
      confirm(state$app, "Are you sure you want to quit?")
      state$set("awaiting", "quit")
      state
    },

    btn_save_settings = function(event, state) {
      pop_screen(state$app, result = list(action = "save"))
      state
    },

    btn_cancel_settings = function(event, state) {
      pop_screen(state$app, result = list(action = "cancel"))
      state
    }
  ),

  on_screen_result = function(event, state) {
    awaiting <- state$get("awaiting")

    if (identical(awaiting, "quit")) {
      state$set("awaiting", NULL)
      if (isTRUE(event$value)) return(quit(state))
    }

    if (identical(awaiting, "settings")) {
      state$set("awaiting", NULL)
      if (is.list(event$value) && event$value$action == "save") {
        notify(state$app, "Settings saved!", severity = "info")
        update(state$app, "user_display",
               content = "Current user: (updated)")
      } else {
        notify(state$app, "Settings cancelled.", severity = "warning")
      }
    }
    state
  },

  bindings = list(
    binding("q", "quit_app", "Quit", priority = TRUE),
    binding("d", "toggle_dark", "Dark mode", priority = TRUE)
  ),
  on_action = function(event, state) {
    if (event$value == "quit_app") return(quit(state))
    if (event$value == "toggle_dark") dark_toggle(state$app)
    state
  },

  css = "
    #main_center { height: 1fr; }
    #main_panel { width: 50; height: auto; padding: 2; }
    #welcome { text-align: center; height: 2; }
    #user_display, #notify_display { text-align: center; height: 1; }
    #main_buttons { height: 3; align: center middle; }
    Button { margin: 0 1; min-width: 12; }
    Rule { margin: 1 0; }
  "
)
