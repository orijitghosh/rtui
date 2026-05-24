#' Create a text input widget
#' @param placeholder Placeholder text.
#' @param value Initial value.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @param tooltip Optional tooltip text.
#' @param validators Optional character vector of validators. Supported:
#'   `"number"`, `"integer"`, `"url"`, or `"regex:PATTERN"`.
#' @return An `rtui_spec` list.
#'
#' @examples
#' \dontrun{
#' # Text input with change and submit handlers
#' quick_app(
#'   layout = vstack(
#'     input(placeholder = "Type your name...", id = "name"),
#'     input(placeholder = "Age", id = "age", validators = "integer"),
#'     static("", id = "output"),
#'     id = "root"
#'   ),
#'   on_submit = list(
#'     name = function(event, state) {
#'       update(state$app, "output",
#'              content = paste("Hello,", event$value))
#'       state
#'     }
#'   ),
#'   on_change = list(
#'     name = function(event, state) {
#'       # event$value contains the current text
#'       state
#'     }
#'   )
#' )
#' }
#'
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
#'
#' @examples
#' \dontrun{
#' quick_app(
#'   layout = vstack(
#'     button("Click Me", id = "btn", tooltip = "Press to greet"),
#'     button("Disabled", id = "off"),
#'     static("", id = "msg"),
#'     id = "root"
#'   ),
#'   on_mount = function(event, state) {
#'     update(state$app, "off", disabled = TRUE)
#'     state
#'   },
#'   on_click = list(
#'     btn = function(event, state) {
#'       update(state$app, "msg", content = "Hello!")
#'       update(state$app, "btn", label = "Clicked!")
#'       state
#'     }
#'   )
#' )
#' }
#'
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
#'
#' @examples
#' \dontrun{
#' quick_app(
#'   layout = vstack(
#'     list_view(items = c("Apple", "Banana", "Cherry"), id = "fruits"),
#'     static("Select a fruit", id = "msg"),
#'     id = "root"
#'   ),
#'   on_change = list(
#'     fruits = function(event, state) {
#'       update(state$app, "msg", content = paste("Selected:", event$value))
#'       state
#'     }
#'   )
#' )
#' }
#'
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
#' A full-featured interactive table with sorting, row/cell/column
#' selection, and zebra striping. For a quick one-liner data explorer,
#' see [data_viewer()].
#'
#' @param df A data.frame to display.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @param cursor Type of cursor: `"cell"`, `"row"` (default), `"column"`, or `"none"`.
#' @param zebra_stripes Whether to show alternating row colours (default FALSE).
#' @param sortable Whether clicking column headers sorts the table (default FALSE).
#'   When `TRUE`, each click toggles ascending/descending sort.
#' @return An `rtui_spec` list.
#'
#' @examples
#' \dontrun{
#' # Interactive sortable table
#' quick_app(
#'   layout = vstack(
#'     header(),
#'     data_table(mtcars, id = "cars",
#'                cursor = "row",
#'                zebra_stripes = TRUE,
#'                sortable = TRUE),
#'     footer()
#'   ),
#'   bindings = list(binding("q", "quit_app", "Quit", priority = TRUE)),
#'   on_action = function(event, state) {
#'     if (event$value == "quit_app") return(quit())
#'     state
#'   }
#' )
#'
#' # Dynamically add rows
#' on_click = list(
#'   add_btn = function(event, state) {
#'     new_row <- data.frame(mpg = 25, cyl = 4, disp = 100)
#'     update(state$app, "cars", add_rows = as.list(new_row))
#'     state
#'   },
#'   clear_btn = function(event, state) {
#'     update(state$app, "cars", clear_data = TRUE)
#'     state
#'   }
#' )
#' }
#'
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
#'
#' @examples
#' \dontrun{
#' quick_app(
#'   layout = vstack(
#'     checkbox("Enable notifications", value = TRUE, id = "notif"),
#'     checkbox("Dark mode", value = FALSE, id = "dark"),
#'     static("", id = "status"),
#'     id = "root"
#'   ),
#'   on_change = list(
#'     notif = function(event, state) {
#'       update(state$app, "status",
#'              content = paste("Notifications:", event$value))
#'       state
#'     },
#'     dark = function(event, state) {
#'       dark_toggle(state$app, event$value)
#'       state
#'     }
#'   )
#' )
#' }
#'
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
#'
#' @examples
#' \dontrun{
#' # See radio_set() for a complete example
#' radio_button("Option A")
#' radio_button("Option B", value = TRUE)  # pre-selected
#' }
#'
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
#'
#' @examples
#' \dontrun{
#' quick_app(
#'   layout = vstack(
#'     static("Choose a size:"),
#'     radio_set(
#'       radio_button("Small"),
#'       radio_button("Medium", value = TRUE),
#'       radio_button("Large"),
#'       id = "size"
#'     ),
#'     static("", id = "chosen"),
#'     id = "root"
#'   ),
#'   on_change = list(
#'     size = function(event, state) {
#'       update(state$app, "chosen",
#'              content = paste("Selected:", event$value))
#'       state
#'     }
#'   )
#' )
#' }
#'
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
#'
#' @examples
#' \dontrun{
#' quick_app(
#'   layout = vstack(
#'     # Simple options
#'     select(c("Red", "Green", "Blue"), id = "color",
#'            prompt = "Pick a colour..."),
#'     # Named options (display => value)
#'     select(c("Small (S)" = "s", "Medium (M)" = "m", "Large (L)" = "l"),
#'            id = "size"),
#'     static("", id = "result"),
#'     id = "root"
#'   ),
#'   on_change = list(
#'     color = function(event, state) {
#'       update(state$app, "result",
#'              content = paste("Colour:", event$value))
#'       state
#'     }
#'   )
#' )
#' }
#'
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
#'
#' @examples
#' \dontrun{
#' quick_app(
#'   layout = vstack(
#'     hstack(static("Dark mode: "), switch_input(value = TRUE, id = "dark")),
#'     hstack(static("Sound: "), switch_input(value = FALSE, id = "sound")),
#'     id = "root"
#'   ),
#'   on_change = list(
#'     dark = function(event, state) {
#'       dark_toggle(state$app, event$value)
#'       state
#'     }
#'   )
#' )
#' }
#'
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
#'
#' @examples
#' \dontrun{
#' quick_app(
#'   layout = vstack(
#'     static("Phone:"),
#'     masked_input(template = "999-999-9999", id = "phone"),
#'     static("Postcode:"),
#'     masked_input(template = "AA99 9AA", id = "postcode"),
#'     static("Date:"),
#'     masked_input(template = "99/99/9999", id = "date"),
#'     id = "root"
#'   )
#' )
#' }
#'
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
#' @param language Optional language for syntax highlighting (e.g. `"r"`,
#'   `"python"`, `"json"`, `"markdown"`, `"sql"`).
#' @param show_line_numbers Show line numbers.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#'
#' @examples
#' \dontrun{
#' # Code editor with syntax highlighting
#' quick_app(
#'   layout = vstack(
#'     text_area(value = "x <- 1:10\nmean(x)\nsd(x)",
#'               language = "r",
#'               show_line_numbers = TRUE,
#'               id = "editor"),
#'     button("Run", id = "run"),
#'     id = "root"
#'   ),
#'   on_change = list(
#'     editor = function(event, state) {
#'       state$set("code", event$value)
#'       state
#'     }
#'   )
#' )
#'
#' # Markdown editor with live preview
#' quick_app(
#'   layout = hstack(
#'     text_area(value = "# Title\n\nSome **bold** text.",
#'               id = "editor", show_line_numbers = TRUE),
#'     markdown("", id = "preview"),
#'     id = "root"
#'   ),
#'   on_change = list(
#'     editor = function(event, state) {
#'       update(state$app, "preview", content = event$value)
#'       state
#'     }
#'   )
#' )
#' }
#'
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
#'
#' A scrollable list of selectable options. Fires `on_change` events
#' when the user highlights or selects an item.
#'
#' @param items Character vector of option items.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#'
#' @examples
#' \dontrun{
#' quick_app(
#'   layout = vstack(
#'     option_list(items = c("Apple", "Banana", "Cherry", "Date"),
#'                 id = "fruits"),
#'     static("Pick a fruit", id = "msg"),
#'     button("Update list", id = "update_btn"),
#'     id = "root"
#'   ),
#'   on_change = list(
#'     fruits = function(event, state) {
#'       update(state$app, "msg", content = paste("Picked:", event$value))
#'       state
#'     }
#'   ),
#'   on_click = list(
#'     update_btn = function(event, state) {
#'       # Replace items dynamically
#'       update(state$app, "fruits", items = c("Fig", "Grape", "Kiwi"))
#'       state
#'     }
#'   )
#' )
#' }
#'
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
#'
#' Like [option_list()] but allows the user to toggle multiple items on/off.
#'
#' @param items Character vector of items.
#' @param id Optional widget id.
#' @param classes Optional CSS classes (character vector).
#' @return An `rtui_spec` list.
#'
#' @examples
#' \dontrun{
#' quick_app(
#'   layout = vstack(
#'     static("Select permissions:"),
#'     selection_list(items = c("Read", "Write", "Execute"),
#'                    id = "perms"),
#'     static("", id = "chosen"),
#'     id = "root"
#'   ),
#'   on_change = list(
#'     perms = function(event, state) {
#'       update(state$app, "chosen",
#'              content = paste("Selected:", toString(event$value)))
#'       state
#'     }
#'   )
#' )
#' }
#'
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
