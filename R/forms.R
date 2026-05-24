#' Create a form with named inputs and a submit button
#'
#' Builds a vertical layout with labelled form fields and a submit button.
#' When the user presses the submit button, all current field values are
#' collected into a named list and passed to the `on_submit` callback.
#'
#' @param ... Named form field specs. Each should be an `rtui_spec` for an
#'   input widget (e.g. `input()`, `select()`, `checkbox()`, `switch_input()`).
#'   The name is used as both the widget id and the display label.
#' @param submit_label Label for the submit button (default `"Submit"`).
#' @param id Optional id for the enclosing container.
#' @param classes Optional CSS classes.
#' @return An `rtui_spec` list representing the form layout.
#'
#' @details
#' The form auto-generates widget ids from the field names (spaces replaced
#' with underscores, lowercased). Use `on_click` with id `"__form_submit"`
#' to handle submission.
#'
#' Field values are also collected and stored in state under `".form_values"`
#' each time a field changes. When submit is clicked the `on_click` handler
#' receives `event$value$form_data` with all current values.
#'
#' @examples
#' \dontrun{
#' quick_app(
#'   layout = vstack(
#'     header(),
#'     tui_form(
#'       Name = input(placeholder = "Your name"),
#'       Email = input(placeholder = "you@example.com", validators = "url"),
#'       Department = select(c("Engineering", "Marketing", "Sales")),
#'       Active = checkbox("Currently active", value = TRUE),
#'       id = "myform"
#'     ),
#'     footer(),
#'     id = "root"
#'   ),
#'   on_click = list(
#'     `__form_submit` = function(event, state) {
#'       vals <- state$get(".form_values", list())
#'       notify(state$app, paste("Name:", vals$name))
#'       state
#'     }
#'   )
#' )
#' }
#'
#' @export
tui_form <- function(..., submit_label = "Submit", id = NULL, classes = NULL) {
  fields <- list(...)
  if (length(fields) == 0L) {
    abort_spec("At least one field is required in `tui_form()`.")
  }
  nms <- names(fields)
  if (is.null(nms) || any(!nzchar(nms))) {
    abort_spec("All fields in `tui_form()` must be named.")
  }
  for (i in seq_along(fields)) {
    if (!inherits(fields[[i]], "rtui_spec")) {
      abort_spec(paste0("Field '", nms[i], "' is not an rtui widget spec."))
    }
  }
  if (!is.character(submit_label) || length(submit_label) != 1L) {
    abort_spec("`submit_label` must be a single character string.")
  }
  validate_id(id)
  validate_classes(classes)

  # Build labelled rows for each field
  children <- list()
  field_ids <- character(length(fields))
  for (i in seq_along(fields)) {
    label_text <- nms[i]
    field_id <- tolower(gsub("\\s+", "_", label_text))
    field_ids[i] <- field_id
    # Assign id to the field spec if it doesn't have one
    field_spec <- fields[[i]]
    if (is.null(field_spec$id)) {
      field_spec$id <- field_id
    } else {
      field_ids[i] <- field_spec$id
    }
    # Create a labelled row
    label_spec <- static(paste0(label_text, ":"), id = paste0("__label_", field_id))
    children <- c(children, list(label_spec), list(field_spec))
  }

  # Add submit button
  submit_btn <- button(submit_label, id = "__form_submit")
  children <- c(children, list(submit_btn))

  # Store field metadata in props for runtime retrieval
  new_spec("vstack", id = id, classes = classes, children = children,
           props = compact(list(.form_field_ids = field_ids)))
}


#' Collect form values from the running app
#'
#' Queries all widget ids from a form and returns a named list of their
#' current values. This is called automatically when the form submit button
#' is clicked, but you can also call it manually from any handler.
#'
#' @param app An `RtuiApp` object.
#' @param field_ids Character vector of widget ids to query.
#' @return A named list of current values.
#' @export
collect_form <- function(app, field_ids) {
  if (!inherits(app, "RtuiApp")) {
    abort_spec("`app` must be an RtuiApp object.")
  }
  if (!is.character(field_ids) || length(field_ids) == 0L) {
    abort_spec("`field_ids` must be a non-empty character vector.")
  }
  py_app <- app$.__enclos_env__$private$.py_app
  if (is.null(py_app)) {
    abort_python("Cannot collect form: app is not running.")
  }
  vals <- list()
  for (fid in field_ids) {
    tryCatch({
      val <- py_app$get_widget_value(fid)
      vals[[fid]] <- val
    }, error = function(e) {
      vals[[fid]] <<- NULL
    })
  }
  vals
}
