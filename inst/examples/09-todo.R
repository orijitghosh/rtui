# Example 09: Todo List
#
# Demonstrates: input + submit, dynamic list updates, checkbox,
#               confirm dialog, screen results, log_view, state.
#
# Run:
#   Rscript inst/examples/09-todo.R

library(rtui)

quick_app(
  title = "Todo List",
  dark = TRUE,

  layout = vstack(
    header(),

    hstack(
      input(placeholder = "Add a new task...", id = "new_task"),
      button("Add", id = "btn_add"),
      id = "input_row"
    ),

    rule(),

    option_list(items = character(0), id = "todo_list"),

    rule(),

    hstack(
      button("Complete", id = "btn_done"),
      button("Delete", id = "btn_delete"),
      button("Clear Done", id = "btn_clear"),
      id = "action_row"
    ),

    static("0 tasks", id = "status"),
    footer(),
    id = "root"
  ),

  on_mount = function(event, state) {
    state$set("tasks", list(
      list(text = "Learn rtui basics", done = FALSE),
      list(text = "Build a terminal app", done = FALSE),
      list(text = "Install R packages", done = TRUE)
    ))
    state$set("selected_idx", 0L)
    set_timer(state$app, 0.1, "init")
    state
  },

  on_timer = function(event, state) {
    if (event$timer_id == "init") {
      refresh_todos(state)
    }
    state
  },

  on_submit = list(
    new_task = function(event, state) {
      task_text <- event$value
      if (!is.null(task_text) && nzchar(trimws(task_text))) {
        tasks <- state$get("tasks")
        tasks <- c(tasks, list(list(text = trimws(task_text), done = FALSE)))
        state$set("tasks", tasks)
        update(state$app, "new_task", value = "")
        refresh_todos(state)
        notify(state$app, "Task added!", severity = "info")
      }
      state
    }
  ),

  on_click = list(
    btn_add = function(event, state) {
      # Collect the input value from form tracking
      vals <- state$get(".form_values", list())
      task_text <- vals$new_task %||% ""
      if (nzchar(trimws(task_text))) {
        tasks <- state$get("tasks")
        tasks <- c(tasks, list(list(text = trimws(task_text), done = FALSE)))
        state$set("tasks", tasks)
        update(state$app, "new_task", value = "")
        refresh_todos(state)
      }
      state
    },

    btn_done = function(event, state) {
      idx <- state$get("selected_idx")
      tasks <- state$get("tasks")
      if (idx >= 1L && idx <= length(tasks)) {
        tasks[[idx]]$done <- !tasks[[idx]]$done
        state$set("tasks", tasks)
        refresh_todos(state)
      }
      state
    },

    btn_delete = function(event, state) {
      idx <- state$get("selected_idx")
      tasks <- state$get("tasks")
      if (idx >= 1L && idx <= length(tasks)) {
        confirm(state$app,
                sprintf("Delete '%s'?", tasks[[idx]]$text),
                title = "Delete Task")
        state$set("delete_pending", TRUE)
      }
      state
    },

    btn_clear = function(event, state) {
      tasks <- state$get("tasks")
      tasks <- Filter(function(t) !t$done, tasks)
      state$set("tasks", tasks)
      state$set("selected_idx", 0L)
      refresh_todos(state)
      notify(state$app, "Cleared completed tasks.", severity = "info")
      state
    }
  ),

  on_change = list(
    todo_list = function(event, state) {
      val <- event$value
      if (is.list(val) && !is.null(val$index)) {
        state$set("selected_idx", val$index + 1L)
      }
      state
    }
  ),

  on_screen_result = function(event, state) {
    if (isTRUE(state$get("delete_pending"))) {
      state$set("delete_pending", FALSE)
      if (isTRUE(event$value)) {
        idx <- state$get("selected_idx")
        tasks <- state$get("tasks")
        if (idx >= 1L && idx <= length(tasks)) {
          tasks[[idx]] <- NULL
          state$set("tasks", tasks)
          state$set("selected_idx", 0L)
          refresh_todos(state)
        }
      }
    }
    state
  },

  bindings = list(
    binding("q", "quit_app", "Quit", priority = TRUE),
    binding("escape", "quit_app", "Quit", priority = TRUE)
  ),
  on_action = function(event, state) {
    if (event$value == "quit_app") return(quit(state))
    state
  },

  css = "
    #input_row { height: 3; padding: 0 1; }
    #new_task { width: 1fr; }
    Button { margin: 0 1; min-width: 10; }
    #todo_list { height: 1fr; margin: 0 1; }
    #action_row { height: 3; align: center middle; }
    #status { height: 1; dock: bottom; padding: 0 1; }
    Rule { margin: 0 1; height: 1; }
  "
)

# Helper: refresh the option list from state
refresh_todos <- function(state) {
  tasks <- state$get("tasks")
  if (length(tasks) == 0) {
    items <- "(no tasks yet)"
  } else {
    items <- vapply(tasks, function(t) {
      prefix <- if (t$done) "✓ " else "○ "
      paste0(prefix, t$text)
    }, character(1))
  }
  update(state$app, "todo_list", items = items)
  done_count <- sum(vapply(tasks, function(t) t$done, logical(1)))
  update(state$app, "status",
         content = sprintf("%d tasks | %d done | %d remaining",
                           length(tasks), done_count,
                           length(tasks) - done_count))
}
