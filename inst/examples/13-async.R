# Example 13: Background Tasks
#
# Demonstrates: run_async(), cancel_async(), on_task handler,
#               progress feedback, error handling.
#
# Run:
#   Rscript inst/examples/13-async.R

library(rtui)

quick_app(
  title = "Async Tasks",
  dark = TRUE,

  layout = vstack(
    header(),
    center(vstack(
      static("[bold]Background Task Demo[/bold]", id = "title_text"),
      rule(),
      static("Ready", id = "status"),
      progress_bar(total = 100, progress = 0, id = "pb"),
      hstack(
        button("Run Slow Task", id = "btn_run"),
        button("Run Failing Task", id = "btn_fail"),
        button("Cancel", id = "btn_cancel"),
        id = "controls"
      ),
      rule(label = "Results"),
      log_view(id = "results", max_lines = 50L),
      id = "panel"
    )),
    footer(),
    id = "root"
  ),

  on_mount = function(event, state) {
    state$set("task_count", 0L)
    state
  },

  on_click = list(
    btn_run = function(event, state) {
      n <- state$get("task_count", 0L) + 1L
      state$set("task_count", n)
      task_name <- paste0("task_", n)

      update(state$app, "status",
             content = paste0("[yellow]Running ", task_name, "...[/yellow]"))
      update(state$app, "pb", progress = 10)

      run_async(state$app, function() {
        Sys.sleep(3)
        list(answer = 42, timestamp = Sys.time())
      }, name = task_name)

      log_write(state$app, "results",
                paste("Started", task_name), markup = FALSE)
      state
    },

    btn_fail = function(event, state) {
      n <- state$get("task_count", 0L) + 1L
      state$set("task_count", n)
      task_name <- paste0("task_", n)

      update(state$app, "status",
             content = paste0("[yellow]Running ", task_name, " (will fail)...[/yellow]"))

      run_async(state$app, function() {
        Sys.sleep(1)
        stop("Something went wrong!")
      }, name = task_name)

      log_write(state$app, "results",
                paste("Started", task_name, "(expect failure)"), markup = FALSE)
      state
    },

    btn_cancel = function(event, state) {
      n <- state$get("task_count", 0L)
      if (n > 0) {
        task_name <- paste0("task_", n)
        cancel_async(state$app, task_name)
        update(state$app, "status", content = "[red]Cancelled[/red]")
        update(state$app, "pb", progress = 0)
        log_write(state$app, "results",
                  paste("Cancelled", task_name), markup = FALSE)
      }
      state
    }
  ),

  on_task = function(event, state) {
    if (event$widget_id == "__async_ok") {
      update(state$app, "status",
             content = paste0("[green]", event$timer_id, " completed![/green]"))
      update(state$app, "pb", progress = 100)
      log_write(state$app, "results",
                paste(event$timer_id, "=> OK:", deparse(event$value)),
                markup = FALSE)
      notify(state$app, paste(event$timer_id, "finished!"), severity = "info")
    } else {
      update(state$app, "status",
             content = paste0("[red]", event$timer_id, " failed![/red]"))
      update(state$app, "pb", progress = 0)
      log_write(state$app, "results",
                paste(event$timer_id, "=> ERROR:", event$value),
                markup = FALSE)
      notify(state$app, paste(event$timer_id, "failed"), severity = "error")
    }
    state
  },

  bindings = list(
    binding("q", "quit_app", "Quit"),
    binding("d", "toggle_dark", "Dark mode")
  ),
  on_action = function(event, state) {
    if (event$value == "quit_app") return(quit(state))
    if (event$value == "toggle_dark") dark_toggle(state$app)
    state
  },

  css = "
    #panel { width: 70; height: 1fr; padding: 1; }
    #controls { height: 3; align: center middle; }
    Button { margin: 0 1; min-width: 16; }
    #results { height: 1fr; margin: 1 0; }
    Rule { margin: 0; }
  "
)
