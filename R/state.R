#' Create a mutable TUI state object
#'
#' @param initial A list of initial state values.
#' @return An R6 object of class `RtuiState`.
#' @export
tui_state <- function(initial = list()) {
  if (!is.list(initial)) {
    abort_spec(
      c("x" = "`initial` must be a list.", "i" = paste0("Got: ", class(initial)[[1]]))
    )
  }
  RtuiState$new(initial)
}

#' Mutable TUI state object
#'
#' An R6 class for managing mutable app state. Created by [tui_state()].
#' Supports reactive bindings that auto-update widgets when values change.
#'
#'
#' @importFrom R6 R6Class
#' @keywords internal
RtuiState <- R6::R6Class(
  "RtuiState",
  public = list(

    #' @description Create a new state object.
    #' @param initial A list of initial state values.
    initialize = function(initial = list()) {
      private$.data <- as.list(initial)
      private$.reactive <- list()
    },

    #' @description Get a value by key.
    #' @param key Character string key.
    #' @param default Value to return if key is not found.
    get = function(key, default = NULL) {
      if (key %in% names(private$.data)) {
        private$.data[[key]]
      } else {
        default
      }
    },

    #' @description Set a value by key. Fires reactive bindings if the value changed.
    #' @param key Character string key.
    #' @param value The value to store.
    set = function(key, value) {
      old <- private$.data[[key]]
      private$.data[[key]] <- value
      # Fire reactive binding if value actually changed
      if (!identical(old, value)) {
        private$fire_reactive(key, value)
      }
      invisible(self)
    },

    #' @description Return state as a plain list (excluding internal keys).
    as_list = function() {
      # Exclude internal keys (start with ".")
      d <- private$.data
      nms <- names(d)
      if (is.null(nms) || length(nms) == 0L) return(d)
      d[!startsWith(nms, ".")]
    },

    #' @description Print the state object.
    #' @param ... Ignored.
    print = function(...) {
      cli::cli_h3("RtuiState")
      nms <- names(private$.data)
      user_nms <- if (is.null(nms)) character(0) else nms[!startsWith(nms, ".")]
      if (length(user_nms) == 0L) {
        cli::cli_text("(empty)")
      } else {
        for (nm in user_nms) {
          val <- private$.data[[nm]]
          cli::cli_text("{.field {nm}}: {.val {val}}")
        }
      }
      if (length(private$.reactive) > 0L) {
        cli::cli_text("Reactive: {.val {paste(names(private$.reactive), collapse = ', ')}}")
      }
      invisible(self)
    }
  ),

  active = list(
    #' @field data Access the raw state data list.
    data = function(value) {
      if (missing(value)) return(private$.data)
      private$.data <- as.list(value)
    },
    #' @field app Access the running app (for calling `update()`, etc.)
    app = function() {
      self$get(".app")
    }
  ),

  private = list(
    .data = list(),
    .reactive = list(),

    fire_reactive = function(key, value) {
      binding <- private$.reactive[[key]]
      if (is.null(binding)) return(invisible(NULL))
      app <- self$get(".app")
      if (is.null(app)) return(invisible(NULL))

      for (b in binding) {
        tryCatch(
          b(value, self, app),
          error = function(e) {
            # Don't crash the app on reactive errors — log via notify
            tryCatch(
              notify(app, paste0("Reactive error (", key, "): ", conditionMessage(e)),
                     severity = "error"),
              error = function(e2) NULL
            )
          }
        )
      }
      invisible(NULL)
    }
  )
)
