#' Create a TUI application
#'
#' **Important:** TUI apps must be run from a real terminal emulator
#' (Windows Terminal, iTerm2, Terminal.app, etc.). They will **not** work in
#' the RStudio console, R GUI, Jupyter, or any embedded R console. Save your
#' code as a `.R` file and run it with `Rscript`.
#'
#' @param layout A widget spec defining the app layout.
#' @param on_mount Callback for the mount event: `function(event, state)`.
#' @param on_key Callback for key events: `function(event, state)`.
#' @param on_click Callback for click/press events. Either a single function
#'   `function(event, state)`, or a **named list** of per-widget handlers
#'   (e.g. `list(save_btn = function(event, state) {...})`).
#' @param on_change Callback for value-change events. Same signature as
#'   `on_click` — single function or named list by widget id.
#' @param on_submit Callback for input submit events (Enter in an Input).
#'   Single function or named list by widget id.
#' @param on_timer Callback for timer events: `function(event, state)`.
#'   `event$timer_id` identifies which timer fired.
#' @param on_action Callback for action events from key bindings:
#'   `function(event, state)` where `event$value` is the action name.
#' @param on_screen_result Callback for screen dismiss results:
#'   `function(event, state)` where `event$value` is the result.
#' @param on_quit Callback for quit event: `function(event, state)`.
#' @param css Optional Textual CSS string.
#' @param title Optional app title (shown in header).
#' @param sub_title Optional app subtitle (shown in header).
#' @param dark Whether to use dark mode (default TRUE).
#' @param reactive Optional reactive bindings created with [reactive()].
#'   Auto-updates widgets when state values change.
#' @param bindings Optional list of key bindings created with [binding()].
#'   Bindings are shown in the footer and dispatch `"action"` events.
#' @return An `RtuiApp` R6 object.
#' @export
tui_app <- function(layout, on_mount = NULL, on_key = NULL, on_click = NULL,
                    on_change = NULL, on_submit = NULL, on_timer = NULL,
                    on_action = NULL, on_screen_result = NULL,
                    on_quit = NULL, css = NULL, title = NULL,
                    sub_title = NULL, dark = TRUE, bindings = NULL,
                    reactive = NULL) {
  if (!inherits(layout, "rtui_spec")) {
    abort_spec("`layout` must be an rtui widget spec.")
  }
  # Validate simple function-or-NULL handlers
  for (nm in c("on_mount", "on_key", "on_quit", "on_timer",
               "on_action", "on_screen_result")) {
    val <- get(nm)
    if (!is.null(val) && !is.function(val)) {
      abort_spec(paste0("`", nm, "` must be a function or NULL."))
    }
  }
  # Validate handlers that accept function OR named list of functions
  for (nm in c("on_click", "on_change", "on_submit")) {
    val <- get(nm)
    if (!is.null(val)) {
      validate_handler_or_map(val, nm)
    }
  }
  if (!is.null(css) && (!is.character(css) || length(css) != 1L)) {
    abort_spec("`css` must be a single character string or NULL.")
  }
  if (!is.null(title) && (!is.character(title) || length(title) != 1L)) {
    abort_spec("`title` must be a single character string or NULL.")
  }
  if (!is.null(sub_title) && (!is.character(sub_title) || length(sub_title) != 1L)) {
    abort_spec("`sub_title` must be a single character string or NULL.")
  }
  if (!is.logical(dark) || length(dark) != 1L) {
    abort_spec("`dark` must be TRUE or FALSE.")
  }
  if (!is.null(bindings)) {
    if (!is.list(bindings) || !all(vapply(bindings, inherits, logical(1), "rtui_binding"))) {
      abort_spec("`bindings` must be a list of binding() objects.")
    }
  }
  if (!is.null(reactive) && !inherits(reactive, "rtui_reactive")) {
    abort_spec("`reactive` must be created with `reactive()`.")
  }

  RtuiApp$new(
    layout = layout,
    on_mount = on_mount,
    on_key = on_key,
    on_click = on_click,
    on_change = on_change,
    on_submit = on_submit,
    on_timer = on_timer,
    on_action = on_action,
    on_screen_result = on_screen_result,
    on_quit = on_quit,
    css = css,
    title = title,
    sub_title = sub_title,
    dark = dark,
    bindings = bindings,
    reactive = reactive
  )
}

#' @importFrom R6 R6Class
RtuiApp <- R6::R6Class(
  "RtuiApp",
  public = list(
    layout = NULL,
    handlers = NULL,
    css = NULL,
    state = NULL,

    title = NULL,
    sub_title = NULL,
    dark = TRUE,
    bindings = NULL,

    initialize = function(layout, on_mount = NULL, on_key = NULL,
                          on_click = NULL, on_change = NULL,
                          on_submit = NULL, on_timer = NULL,
                          on_action = NULL, on_screen_result = NULL,
                          on_quit = NULL, css = NULL, title = NULL,
                          sub_title = NULL, dark = TRUE, bindings = NULL,
                          reactive = NULL) {
      self$layout <- layout
      self$handlers <- compact(list(
        mount = on_mount,
        key = on_key,
        click = on_click,
        change = on_change,
        submit = on_submit,
        timer = on_timer,
        action = on_action,
        screen_result = on_screen_result,
        quit = on_quit
      ))
      self$css <- css
      self$title <- title
      self$sub_title <- sub_title
      self$dark <- dark
      self$bindings <- bindings
      self$state <- tui_state()
      private$.exit_requested <- FALSE
      private$.exit_result <- NULL
      # Install reactive bindings into the state object
      if (!is.null(reactive)) {
        self$state$.__enclos_env__$private$.reactive <- reactive
      }
    },

    run = function() {
      check_terminal()
      # Make `app` accessible from state so quick_app handlers can call update()
      self$state$set(".app", self)
      shim <- load_shim()

      # Convert bindings to plain lists for Python
      py_bindings <- NULL
      if (!is.null(self$bindings)) {
        py_bindings <- lapply(self$bindings, function(b) {
          list(key = b$key, action = b$action, description = b$description,
               priority = isTRUE(b$priority))
        })
      }

      py_app <- shim$app$RtuiApp(
        spec = self$layout,
        callback_dispatcher = private$dispatch,
        css_text = self$css,
        title = self$title,
        sub_title = self$sub_title,
        dark = self$dark,
        bindings = py_bindings
      )
      private$.py_app <- py_app

      tryCatch(
        py_app$run(),
        error = function(e) {
          private$.py_app <- NULL
          abort_python(
            c("x" = "Textual app exited with an error.",
              "i" = conditionMessage(e)),
            parent = e
          )
        }
      )

      private$.py_app <- NULL
      invisible(self$state)
    },

    exit = function(result = NULL) {
      private$.exit_requested <- TRUE
      private$.exit_result <- result
      if (!is.null(private$.py_app)) {
        private$.py_app$request_exit(result)
      }
      invisible(self)
    },

    print = function(...) {
      cli::cli_h3("RtuiApp")
      cli::cli_text("Layout: {.val {self$layout$kind}}")
      handlers_str <- paste(names(self$handlers), collapse = ", ")
      if (nzchar(handlers_str)) {
        cli::cli_text("Handlers: {.val {handlers_str}}")
      }
      invisible(self)
    }
  ),

  private = list(
    .py_app = NULL,
    .exit_requested = FALSE,
    .exit_result = NULL,

    dispatch = function(event_dict) {
      event <- as_r_event(event_dict)
      handler <- self$handlers[[event$type]]
      if (is.null(handler)) return(self$state$as_list())

      # Per-widget-id routing: if handler is a named list, look up by widget_id
      if (is.list(handler) && !is.function(handler)) {
        widget_id <- event$widget_id
        if (is.null(widget_id) || is.null(handler[[widget_id]])) {
          # No handler for this widget — check for a ".default" catch-all
          handler <- handler[[".default"]]
          if (is.null(handler)) return(self$state$as_list())
        } else {
          handler <- handler[[widget_id]]
        }
      }

      result <- tryCatch(
        handler(event, self$state),
        error = function(e) {
          cli::cli_warn(c(
            "x" = paste0("Error in ", event$type, " callback."),
            "i" = conditionMessage(e)
          ))
          return(NULL)
        }
      )
      if (is.null(result)) return(self$state$as_list())

      if (inherits(result, "rtui_quit")) {
        private$.exit_requested <- TRUE
        private$.exit_result <- result$result
        if (!is.null(private$.py_app)) {
          private$.py_app$request_exit(result$result)
        }
        return(self$state$as_list())
      }

      if (inherits(result, "RtuiState")) {
        self$state <- result
      } else if (is.list(result)) {
        self$state$data <- result
      }

      self$state$as_list()
    }
  )
)


# -- Internal validator for handlers that accept function OR named list ------

validate_handler_or_map <- function(val, label) {
  if (is.function(val)) return(invisible(NULL))
  if (is.list(val) && length(val) > 0L) {
    nms <- names(val)
    if (is.null(nms) || any(!nzchar(nms))) {
      abort_spec(paste0(
        "`", label, "` list must be fully named ",
        "(e.g. list(btn_id = function(event, state) {...}))."
      ))
    }
    for (nm in nms) {
      if (!is.function(val[[nm]])) {
        abort_spec(paste0(
          "`", label, "[[\"", nm, "\"]]` must be a function."
        ))
      }
    }
    return(invisible(NULL))
  }
  abort_spec(paste0(
    "`", label, "` must be a function or a named list of functions."
  ))
}


#' Run a TUI app in one call
#'
#' Convenience wrapper around [tui_app()] that creates and immediately runs
#' the application, returning the final state. Ideal for simple single-screen
#' apps.
#'
#' **Important:** Must be run from a real terminal (not RStudio, R GUI, or
#' Jupyter). Save your code as a `.R` file and run with `Rscript my_app.R`.
#'
#' @inheritParams tui_app
#' @return The final `RtuiState` object (invisibly).
#' @export
quick_app <- function(...) {
  app <- tui_app(...)
  app$run()
}
