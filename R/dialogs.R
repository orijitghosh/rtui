#' Show a confirmation dialog
#'
#' Pushes a modal screen with a message and Yes/No buttons. The result
#' is dispatched as a `"screen_result"` event with `event$value` set to
#' `TRUE` (confirmed) or `FALSE` (cancelled).
#'
#' @param app An `RtuiApp` object (or accessed via `state$app`).
#' @param message The question or message to display.
#' @param title Optional dialog title (default `"Confirm"`).
#' @param yes_label Label for the confirm button (default `"Yes"`).
#' @param no_label Label for the cancel button (default `"No"`).
#' @return Invisible `app`.
#'
#' @examples
#' \dontrun{
#' quick_app(
#'   layout = vstack(
#'     button("Delete All", id = "del"),
#'     footer(),
#'     id = "root"
#'   ),
#'   on_click = list(
#'     del = function(event, state) {
#'       confirm(state$app, "Are you sure you want to delete everything?")
#'       state
#'     }
#'   ),
#'   on_screen_result = function(event, state) {
#'     if (isTRUE(event$value)) {
#'       notify(state$app, "Deleted!", severity = "warning")
#'     }
#'     state
#'   }
#' )
#' }
#'
#' @export
confirm <- function(app, message, title = "Confirm",
                    yes_label = "Yes", no_label = "No") {
  if (!inherits(app, "RtuiApp")) {
    abort_spec("`app` must be an RtuiApp object.")
  }
  if (!is.character(message) || length(message) != 1L) {
    abort_spec("`message` must be a single character string.")
  }

  screen <- tui_screen(
    layout = center(
      middle(
        vstack(
          static(title, id = "__dlg_title", classes = "dlg-title"),
          static(message, id = "__dlg_message", classes = "dlg-message"),
          hstack(
            button(yes_label, id = "__dlg_yes"),
            button(no_label, id = "__dlg_no"),
            id = "__dlg_buttons",
            classes = "dlg-buttons"
          ),
          id = "__dlg_content",
          classes = "dlg-content"
        ),
        id = "__dlg_mid"
      ),
      id = "__dlg_center"
    ),
    css = paste0(
      "#__dlg_content { width: 50; height: auto; ",
      "border: heavy $accent; padding: 1 2; background: $surface; } ",
      ".dlg-title { text-style: bold; text-align: center; width: 100%; } ",
      ".dlg-message { text-align: center; width: 100%; margin: 1 0; } ",
      ".dlg-buttons { align: center middle; width: 100%; } ",
      "Button { margin: 0 1; min-width: 10; }"
    )
  )
  push_screen(app, screen)
  invisible(app)
}


#' Show an alert dialog
#'
#' Pushes a modal screen with a message and an OK button. Dismisses with
#' `event$value = TRUE` in the `"screen_result"` handler.
#'
#' @param app An `RtuiApp` object.
#' @param message The message to display.
#' @param title Optional dialog title (default `"Alert"`).
#' @param ok_label Label for the OK button (default `"OK"`).
#' @return Invisible `app`.
#'
#' @examples
#' \dontrun{
#' quick_app(
#'   layout = vstack(
#'     button("Show Info", id = "info"),
#'     footer(),
#'     id = "root"
#'   ),
#'   on_click = list(
#'     info = function(event, state) {
#'       alert(state$app, "Operation completed successfully!")
#'       state
#'     }
#'   )
#' )
#' }
#'
#' @export
alert <- function(app, message, title = "Alert", ok_label = "OK") {
  if (!inherits(app, "RtuiApp")) {
    abort_spec("`app` must be an RtuiApp object.")
  }
  if (!is.character(message) || length(message) != 1L) {
    abort_spec("`message` must be a single character string.")
  }

  screen <- tui_screen(
    layout = center(
      middle(
        vstack(
          static(title, id = "__dlg_title", classes = "dlg-title"),
          static(message, id = "__dlg_message", classes = "dlg-message"),
          hstack(
            button(ok_label, id = "__dlg_yes"),
            id = "__dlg_buttons",
            classes = "dlg-buttons"
          ),
          id = "__dlg_content",
          classes = "dlg-content"
        ),
        id = "__dlg_mid"
      ),
      id = "__dlg_center"
    ),
    css = paste0(
      "#__dlg_content { width: 50; height: auto; ",
      "border: heavy $accent; padding: 1 2; background: $surface; } ",
      ".dlg-title { text-style: bold; text-align: center; width: 100%; } ",
      ".dlg-message { text-align: center; width: 100%; margin: 1 0; } ",
      ".dlg-buttons { align: center middle; width: 100%; } ",
      "Button { margin: 0 1; min-width: 10; }"
    )
  )
  push_screen(app, screen)
  invisible(app)
}
