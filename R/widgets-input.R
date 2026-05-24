#' Create a text input widget
#' @param placeholder Placeholder text.
#' @param value Initial value.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @param tooltip Optional tooltip text.
#' @param validators Optional character vector of validators. Supported:
#'   `"number"`, `"integer"`, `"url"`, or `"regex:PATTERN"`.
#' @return An `rtui_spec` list.
#' @export
input <- function(placeholder = "", value = "", id = NULL, classes = NULL,
                  tooltip = NULL, validators = NULL) {
  if (!is.character(placeholder) || length(placeholder) != 1L) {
    abort_spec("`placeholder` must be a single character string.")
  }
  if (!is.character(value) || length(value) != 1L) {
    abort_spec("`value` must be a single character string.")
  }
  if (!is.null(validators) && !is.character(validators)) {
    abort_spec("`validators` must be a character vector or NULL.")
  }
  validate_id(id)
  validate_classes(classes)
  new_spec("input", id = id, classes = classes,
           props = compact(list(placeholder = placeholder, value = value,
                                tooltip = tooltip, validators = validators)))
}

#' Create a button widget
#' @param label Button label text.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @param tooltip Optional tooltip text shown on hover.
#' @return An `rtui_spec` list.
#' @export
button <- function(label, id = NULL, classes = NULL, tooltip = NULL) {
  if (!is.character(label) || length(label) != 1L) {
    abort_spec("`label` must be a single character string.")
  }
  validate_id(id)
  validate_classes(classes)
  new_spec("button", id = id, classes = classes,
           props = compact(list(label = label, tooltip = tooltip)))
}

#' Create a list view widget
#' @param items Character vector of list items.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#' @export
list_view <- function(items, id = NULL, classes = NULL) {
  if (!is.character(items)) {
    abort_spec("`items` must be a character vector.")
  }
  validate_id(id)
  validate_classes(classes)
  new_spec("list_view", id = id, classes = classes,
           props = list(items = items))
}

#' Create a data table widget
#'
#' @param df A data.frame to display.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @param cursor Type of cursor: `"cell"`, `"row"` (default), `"column"`, or `"none"`.
#' @param zebra_stripes Whether to show alternating row colours (default FALSE).
#' @param sortable Whether clicking column headers sorts the table (default FALSE).
#'   When `TRUE`, each click toggles ascending/descending sort.
#' @return An `rtui_spec` list.
#' @export
data_table <- function(df, id = NULL, classes = NULL,
                       cursor = c("row", "cell", "column", "none"),
                       zebra_stripes = FALSE, sortable = FALSE) {
  if (!is.data.frame(df)) {
    abort_spec("`df` must be a data.frame.")
  }
  cursor <- rlang::arg_match(cursor)
  if (!is.logical(zebra_stripes) || length(zebra_stripes) != 1L) {
    abort_spec("`zebra_stripes` must be TRUE or FALSE.")
  }
  if (!is.logical(sortable) || length(sortable) != 1L) {
    abort_spec("`sortable` must be TRUE or FALSE.")
  }
  validate_id(id)
  validate_classes(classes)
  new_spec("data_table", id = id, classes = classes,
           props = list(df = df, cursor = cursor,
                        zebra_stripes = zebra_stripes, sortable = sortable))
}

#' Create a checkbox widget
#' @param label Checkbox label text.
#' @param value Initial checked state (logical).
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @param tooltip Optional tooltip text shown on hover.
#' @return An `rtui_spec` list.
#' @export
checkbox <- function(label, value = FALSE, id = NULL, classes = NULL,
                     tooltip = NULL) {
  if (!is.character(label) || length(label) != 1L) {
    abort_spec("`label` must be a single character string.")
  }
  if (!is.logical(value) || length(value) != 1L) {
    abort_spec("`value` must be TRUE or FALSE.")
  }
  validate_id(id)
  validate_classes(classes)
  new_spec("checkbox", id = id, classes = classes,
           props = compact(list(label = label, value = value,
                                tooltip = tooltip)))
}

#' Create a radio button widget (use inside radio_set)
#' @param label Radio button label text.
#' @param value Whether this button is selected.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#' @export
radio_button <- function(label, value = FALSE, id = NULL, classes = NULL) {
  if (!is.character(label) || length(label) != 1L) {
    abort_spec("`label` must be a single character string.")
  }
  if (!is.logical(value) || length(value) != 1L) {
    abort_spec("`value` must be TRUE or FALSE.")
  }
  validate_id(id)
  validate_classes(classes)
  new_spec("radio_button", id = id, classes = classes,
           props = list(label = label, value = value))
}

#' Create a radio set (group of radio buttons)
#' @param ... Radio button specs.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#' @export
radio_set <- function(..., id = NULL, classes = NULL) {
  children <- list(...)
  validate_children(children)
  validate_id(id)
  validate_classes(classes)
  new_spec("radio_set", id = id, classes = classes, children = children)
}

#' Create a select dropdown widget
#' @param options Named character vector (values displayed, names used as keys)
#'   or unnamed character vector (values used as both keys and display).
#' @param value Initial selected value (or NULL for no selection).
#' @param prompt Placeholder text when nothing is selected.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @param tooltip Optional tooltip text shown on hover.
#' @return An `rtui_spec` list.
#' @export
select <- function(options, value = NULL, prompt = "Select...",
                   id = NULL, classes = NULL, tooltip = NULL) {
  if (!is.character(options)) {
    abort_spec("`options` must be a character vector.")
  }
  if (!is.null(value) && (!is.character(value) || length(value) != 1L)) {
    abort_spec("`value` must be a single character string or NULL.")
  }
  if (!is.character(prompt) || length(prompt) != 1L) {
    abort_spec("`prompt` must be a single character string.")
  }
  validate_id(id)
  validate_classes(classes)
  new_spec("select", id = id, classes = classes,
           props = compact(list(options = options, value = value,
                                prompt = prompt, tooltip = tooltip)))
}

#' Create a switch (toggle) widget
#' @param value Initial state (logical).
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @param tooltip Optional tooltip text shown on hover.
#' @return An `rtui_spec` list.
#' @export
switch_input <- function(value = FALSE, id = NULL, classes = NULL,
                         tooltip = NULL) {
  if (!is.logical(value) || length(value) != 1L) {
    abort_spec("`value` must be TRUE or FALSE.")
  }
  validate_id(id)
  validate_classes(classes)
  new_spec("switch", id = id, classes = classes,
           props = compact(list(value = value, tooltip = tooltip)))
}

#' Create a masked input widget
#'
#' Template uses special characters: `A` (letter), `9` (digit), `!` (force upper),
#' `>` (force upper following), `<` (force lower following). Other characters are
#' literal separators. Example: `"999-999-9999"` for phone, `"AA99 AA"` for UK postcode.
#'
#' @param template Template string defining the input mask.
#' @param value Initial value (or NULL).
#' @param placeholder Placeholder text.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#' @export
masked_input <- function(template, value = NULL, placeholder = "",
                         id = NULL, classes = NULL) {
  if (!is.character(template) || length(template) != 1L) {
    abort_spec("`template` must be a single character string.")
  }
  if (!is.null(value) && (!is.character(value) || length(value) != 1L)) {
    abort_spec("`value` must be a single character string or NULL.")
  }
  if (!is.character(placeholder) || length(placeholder) != 1L) {
    abort_spec("`placeholder` must be a single character string.")
  }
  validate_id(id)
  validate_classes(classes)
  new_spec("masked_input", id = id, classes = classes,
           props = compact(list(
             template = template, value = value, placeholder = placeholder
           )))
}

#' Create a multi-line text area widget
#' @param value Initial text content.
#' @param language Optional language for syntax highlighting.
#' @param show_line_numbers Show line numbers.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#' @export
text_area <- function(value = "", language = NULL, show_line_numbers = FALSE,
                      id = NULL, classes = NULL) {
  if (!is.character(value) || length(value) != 1L) {
    abort_spec("`value` must be a single character string.")
  }
  if (!is.null(language) && (!is.character(language) || length(language) != 1L)) {
    abort_spec("`language` must be a single character string or NULL.")
  }
  if (!is.logical(show_line_numbers) || length(show_line_numbers) != 1L) {
    abort_spec("`show_line_numbers` must be TRUE or FALSE.")
  }
  validate_id(id)
  validate_classes(classes)
  new_spec("text_area", id = id, classes = classes,
           props = compact(list(
             value = value, language = language,
             show_line_numbers = show_line_numbers
           )))
}

#' Create an option list widget
#' @param items Character vector of option items.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#' @export
option_list <- function(items, id = NULL, classes = NULL) {
  if (!is.character(items)) {
    abort_spec("`items` must be a character vector.")
  }
  validate_id(id)
  validate_classes(classes)
  new_spec("option_list", id = id, classes = classes,
           props = list(items = items))
}

#' Create a selection list (multi-select)
#' @param items Character vector of items.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#' @export
selection_list <- function(items, id = NULL, classes = NULL) {
  if (!is.character(items)) {
    abort_spec("`items` must be a character vector.")
  }
  validate_id(id)
  validate_classes(classes)
  new_spec("selection_list", id = id, classes = classes,
           props = list(items = items))
}
