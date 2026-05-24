# Bridge to Python shim via reticulate

rtui_env <- new.env(parent = emptyenv())

load_shim <- function() {
  if (!is.null(rtui_env$shim)) return(rtui_env$shim)

  shim_path <- system.file("python", package = "rtui")
  if (!nzchar(shim_path)) {
    abort_python("Cannot locate rtui Python shim. Is the package installed correctly?")
  }

  tryCatch(
    {
      rtui_env$shim <- reticulate::import_from_path("rtui_shim", shim_path)
      rtui_env$shim
    },
    error = function(e) {
      abort_python(
        c("x" = "Failed to import rtui Python shim.",
          "i" = "Run `rtui::install_python_deps()` first.",
          "i" = conditionMessage(e)),
        parent = e
      )
    }
  )
}

as_r_event <- function(event_dict) {
  list(
    type = event_dict[["type"]],
    key = event_dict[["key"]] %||% NA_character_,
    widget_id = event_dict[["widget_id"]] %||% NA_character_,
    value = event_dict[["value"]],
    width = event_dict[["width"]] %||% NA_integer_,
    height = event_dict[["height"]] %||% NA_integer_,
    timer_id = event_dict[["timer_id"]] %||% NA_character_,
    timestamp = Sys.time()
  )
}

`%||%` <- function(x, y) if (is.null(x)) y else x
