#' Define reactive bindings between state keys and widgets
#'
#' Reactive bindings auto-update widgets when state values change. Instead
#' of manually calling `update()` after every `state$set()`, declare the
#' relationship once and let rtui handle the rest.
#'
#' @param ... Named arguments defining bindings. Each name is a state key,
#'   and each value is one of:
#'   \describe{
#'     \item{character}{Widget id — sets the widget's `value` to the new state
#'       value. E.g. `count = "display"` updates the `"display"` widget's
#'       value whenever `state$set("count", x)` is called.}
#'     \item{formula}{A one-sided formula `~ expr` where `.x` is the new
#'       value, `.state` is the state object, and `.app` is the running app.
#'       E.g. `count = ~ update(.app, "display", value = paste("Count:", .x))`}
#'     \item{function}{A function `function(value, state, app)` for full
#'       control. Called whenever the state key changes.}
#'     \item{list}{A list of any of the above, to bind multiple widgets
#'       to the same state key.}
#'   }
#' @return A list of class `"rtui_reactive"` to pass to [tui_app()] or
#'   [quick_app()].
#'
#' @examples
#' \dontrun{
#' # Simple: state$count auto-updates the "display" widget's value
#' quick_app(
#'   layout = vstack(
#'     digits("0", id = "display"),
#'     button("+1", id = "inc"),
#'     id = "root"
#'   ),
#'   reactive = reactive(
#'     count = "display"
#'   ),
#'   on_click = list(
#'     inc = function(event, state) {
#'       state$set("count", state$get("count", 0L) + 1L)
#'       state
#'     }
#'   )
#' )
#'
#' # Formula: transform the value before updating
#' reactive(
#'   count = ~ update(.app, "label", content = paste("Count is", .x))
#' )
#'
#' # Function: full control
#' reactive(
#'   temperature = function(value, state, app) {
#'     update(app, "temp_display", value = paste0(value, "°C"))
#'     if (value > 100) notify(app, "Overheating!", severity = "warning")
#'   }
#' )
#'
#' # Multiple widgets from one key
#' reactive(
#'   count = list("display", ~ update(.app, "label", content = paste("N:", .x)))
#' )
#' }
#'
#' @export
reactive <- function(...) {
  bindings <- list(...)
  if (length(bindings) == 0L) {
    abort_spec("At least one binding is required in `reactive()`.")
  }
  nms <- names(bindings)
  if (is.null(nms) || any(!nzchar(nms))) {
    abort_spec("All bindings in `reactive()` must be named (state key = binding).")
  }

  # Normalize each binding into a list of functions
  normalized <- list()
  for (nm in nms) {
    val <- bindings[[nm]]
    fns <- normalize_binding(val, nm)
    normalized[[nm]] <- fns
  }

  structure(normalized, class = "rtui_reactive")
}


# --- Internal helpers ---

normalize_binding <- function(val, key) {
  if (is.character(val) && length(val) == 1L) {
    # Simple: widget id — auto-update its value
    widget_id <- val
    return(list(make_value_updater(widget_id)))
  }
  if (inherits(val, "formula")) {
    return(list(make_formula_fn(val, key)))
  }
  if (is.function(val)) {
    return(list(val))
  }
  if (is.list(val)) {
    # List of bindings for the same key
    fns <- list()
    for (i in seq_along(val)) {
      sub <- val[[i]]
      sub_fns <- normalize_binding(sub, key)
      fns <- c(fns, sub_fns)
    }
    return(fns)
  }
  abort_spec(paste0(
    "Reactive binding for '", key,
    "' must be a widget id (string), formula, function, or list of those."
  ))
}

make_value_updater <- function(widget_id) {
  force(widget_id)
  function(value, state, app) {
    update(app, widget_id, value = as.character(value))
  }
}

make_formula_fn <- function(f, key) {
  force(f)
  force(key)
  fn_env <- rlang::new_environment(parent = environment(f))
  function(value, state, app) {
    fn_env$.x <- value
    fn_env$.state <- state
    fn_env$.app <- app
    eval(rlang::f_rhs(f), envir = fn_env)
  }
}
