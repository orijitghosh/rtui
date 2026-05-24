# Showcase: Markdown Notes
#
# A terminal note-taking app with:
# - Create, edit, and delete notes
# - Live markdown preview
# - Search/filter notes
# - Persistent storage (JSON file)
# - Confirm dialogs for delete
#
# Run from a REAL TERMINAL:
#   & "C:\Program Files\R\R-4.4.3\bin\Rscript.exe" spikes/showcase_notes.R

Sys.unsetenv("RETICULATE_PYTHON")
Sys.setenv(RETICULATE_PYTHON_ENV = "r-rtui")

library(reticulate)
use_virtualenv("r-rtui", required = TRUE)

devtools::load_all(".")

message("--- Markdown Notes ---")
message("Create and manage notes in your terminal.")
message("Press q to quit.")

# --- Storage helpers ---
NOTES_FILE <- file.path(tempdir(), "rtui_notes.rds")

load_notes <- function() {
  if (file.exists(NOTES_FILE)) {
    tryCatch(
      readRDS(NOTES_FILE),
      error = function(e) list())
  } else {
    # Start with sample notes
    list(
      list(
        id = 1L,
        title = "Welcome to Notes",
        body = paste0(
          "# Welcome!\n\n",
          "This is a **markdown** note-taking app built with `rtui`.\n\n",
          "## Features\n\n",
          "- Create new notes with the **New** button\n",
          "- Edit notes in the text area\n",
          "- See a live markdown preview\n",
          "- Delete notes you no longer need\n",
          "- Search by title\n"
        ),
        created = format(Sys.time(), "%Y-%m-%d %H:%M"),
        modified = format(Sys.time(), "%Y-%m-%d %H:%M")
      ),
      list(
        id = 2L,
        title = "R Tips",
        body = paste0(
          "# R Tips\n\n",
          "## Pipe operator\n\n",
          "Use `|>` (base R 4.1+) or `%>%` (magrittr).\n\n",
          "```r\n",
          "mtcars |> head(3)\n",
          "```\n\n",
          "## Quick summary\n\n",
          "- `str()` — structure\n",
          "- `summary()` — stats\n",
          "- `glimpse()` — tidyverse overview\n"
        ),
        created = format(Sys.time(), "%Y-%m-%d %H:%M"),
        modified = format(Sys.time(), "%Y-%m-%d %H:%M")
      ),
      list(
        id = 3L,
        title = "Shopping List",
        body = paste0(
          "# Shopping List\n\n",
          "- [ ] Milk\n",
          "- [ ] Eggs\n",
          "- [x] Bread\n",
          "- [ ] Coffee beans\n",
          "- [x] Butter\n"
        ),
        created = format(Sys.time(), "%Y-%m-%d %H:%M"),
        modified = format(Sys.time(), "%Y-%m-%d %H:%M")
      )
    )
  }
}

save_notes <- function(notes) {
  tryCatch(
    saveRDS(notes, NOTES_FILE),
    error = function(e) NULL
  )
}

next_id <- function(notes) {
  if (length(notes) == 0) return(1L)
  max(vapply(notes, function(n) n$id, integer(1))) + 1L
}

# --- Helper functions (must be defined before quick_app runs) ---

refresh_list <- function(state) {
  notes <- state$get("notes")
  search <- state$get("search_term")

  if (!is.null(search) && nzchar(search)) {
    keep <- vapply(notes, function(n) {
      grepl(search, n$title, ignore.case = TRUE)
    }, logical(1))
    filtered <- notes[keep]
  } else {
    filtered <- notes
  }

  items <- vapply(filtered, function(n) {
    sprintf("%s  [%s]", n$title, n$modified)
  }, character(1))

  if (length(items) == 0) items <- "  (no notes)"
  update(state$app, "note_list", items = items)
}

select_note <- function(state, idx) {
  notes <- state$get("notes")
  if (idx < 1L || idx > length(notes)) return(invisible(NULL))

  state$set("selected_idx", idx)
  note <- notes[[idx]]

  state$set("current_title", note$title)
  state$set("current_body", note$body)

  update(state$app, "title_input", value = note$title)
  update(state$app, "editor", value = note$body)
  update(state$app, "preview", content = note$body)
}

# --- Build the app ---
quick_app(
  title = "Markdown Notes",
  dark = TRUE,

  layout = vstack(
    header(),

    hstack(
      # Left sidebar: note list
      vstack(
        hstack(
          input(placeholder = "Search notes...", id = "search_input"),
          id = "search_bar"
        ),
        rule(),
        option_list(items = character(0), id = "note_list"),
        hstack(
          button("+ New", id = "btn_new"),
          button("Delete", id = "btn_delete"),
          id = "sidebar_buttons"
        ),
        static("0 notes", id = "note_count"),
        id = "sidebar"
      ),

      # Right panel: editor + preview
      vstack(
        # Title editor
        hstack(
          static("[bold]Title:[/bold]", id = "title_label"),
          input(placeholder = "Note title...", id = "title_input"),
          button("Save", id = "btn_save"),
          id = "title_bar"
        ),
        rule(),

        # Editor and preview side by side
        hstack(
          # Editor
          vstack(
            static("[bold dim]Editor[/bold dim]", id = "editor_label"),
            text_area(value = "", id = "editor", show_line_numbers = TRUE),
            id = "editor_panel"
          ),
          # Preview
          vstack(
            static("[bold dim]Preview[/bold dim]", id = "preview_label"),
            markdown("*Select a note to preview*", id = "preview"),
            id = "preview_panel"
          ),
          id = "content_area"
        ),

        id = "main_panel"
      ),

      id = "main_layout"
    ),

    # Status bar
    static("Ready. Press Ctrl+P for command palette.", id = "status_bar"),

    footer(),
    id = "root"
  ),

  on_mount = function(event, state) {
    state$set("notes", load_notes())
    state$set("selected_idx", 0L)
    state$set("search_term", "")
    state$set("delete_pending", FALSE)

    set_timer(state$app, 0.1, "init_list")
    state
  },

  on_timer = function(event, state) {
    if (event$timer_id == "init_list") {
      refresh_list(state)
      notes <- state$get("notes")
      if (length(notes) > 0) {
        select_note(state, 1L)
      }
      update(state$app, "note_count",
             content = sprintf("[dim]%d notes[/dim]", length(notes)))
      update(state$app, "status_bar",
             content = sprintf("Loaded %d notes. Press Ctrl+P for commands.",
                               length(notes)))
    }
    state
  },

  on_change = list(
    search_input = function(event, state) {
      state$set("search_term", event$value)
      refresh_list(state)
      state
    },
    editor = function(event, state) {
      # Live preview update + track body
      if (!is.null(event$value)) {
        state$set("current_body", event$value)
        if (nzchar(event$value)) {
          update(state$app, "preview", content = event$value)
        }
      }
      state
    },
    title_input = function(event, state) {
      state$set("current_title", event$value)
      state
    },
    note_list = function(event, state) {
      # OptionList highlight fires on arrow nav — select note
      val <- event$value
      if (is.list(val) && !is.null(val$index)) {
        # Map back to the full notes list accounting for search filter
        notes <- state$get("notes")
        search <- state$get("search_term")
        if (!is.null(search) && nzchar(search)) {
          keep <- which(vapply(notes, function(n) {
            grepl(search, n$title, ignore.case = TRUE)
          }, logical(1)))
          actual_idx <- keep[val$index + 1L]
        } else {
          actual_idx <- val$index + 1L
        }
        if (!is.na(actual_idx)) select_note(state, actual_idx)
      }
      state
    }
  ),

  on_click = list(
    btn_new = function(event, state) {
      notes <- state$get("notes")
      new_note <- list(
        id = next_id(notes),
        title = "Untitled Note",
        body = "# New Note\n\nStart writing here...\n",
        created = format(Sys.time(), "%Y-%m-%d %H:%M"),
        modified = format(Sys.time(), "%Y-%m-%d %H:%M")
      )
      notes <- c(notes, list(new_note))
      state$set("notes", notes)
      save_notes(notes)
      refresh_list(state)
      select_note(state, length(notes))
      update(state$app, "note_count",
             content = sprintf("[dim]%d notes[/dim]", length(notes)))
      notify(state$app, "New note created.", severity = "info")
      update(state$app, "status_bar",
             content = sprintf("Created note #%d", new_note$id))
      state
    },

    btn_save = function(event, state) {
      idx <- state$get("selected_idx")
      notes <- state$get("notes")
      if (idx < 1L || idx > length(notes)) {
        notify(state$app, "No note selected.", severity = "warning")
        return(state)
      }

      # Get current values from a snapshot approach
      # The editor value comes via on_change, store it in state
      title_val <- state$get("current_title")
      body_val <- state$get("current_body")

      if (!is.null(title_val) && nzchar(title_val)) {
        notes[[idx]]$title <- title_val
      }
      if (!is.null(body_val)) {
        notes[[idx]]$body <- body_val
      }
      notes[[idx]]$modified <- format(Sys.time(), "%Y-%m-%d %H:%M")
      state$set("notes", notes)
      save_notes(notes)
      refresh_list(state)
      notify(state$app, sprintf("Saved: %s", notes[[idx]]$title), severity = "info")
      update(state$app, "status_bar",
             content = sprintf("Saved '%s' at %s",
                               notes[[idx]]$title,
                               format(Sys.time(), "%H:%M:%S")))
      state
    },

    btn_delete = function(event, state) {
      idx <- state$get("selected_idx")
      notes <- state$get("notes")
      if (idx < 1L || idx > length(notes)) {
        notify(state$app, "No note selected.", severity = "warning")
        return(state)
      }
      # Use confirm dialog
      state$set("delete_pending", TRUE)
      confirm(state$app,
              sprintf("Delete '%s'?", notes[[idx]]$title),
              title = "Delete Note")
      state
    }
  ),

  on_screen_result = function(event, state) {
    if (isTRUE(state$get("delete_pending"))) {
      state$set("delete_pending", FALSE)
      if (isTRUE(event$value)) {
        idx <- state$get("selected_idx")
        notes <- state$get("notes")
        if (idx >= 1L && idx <= length(notes)) {
          deleted_title <- notes[[idx]]$title
          notes[[idx]] <- NULL
          state$set("notes", notes)
          save_notes(notes)
          refresh_list(state)
          if (length(notes) > 0) {
            select_note(state, min(idx, length(notes)))
          } else {
            state$set("selected_idx", 0L)
            update(state$app, "title_input", value = "")
            update(state$app, "editor", value = "")
            update(state$app, "preview", content = "*No notes*")
          }
          update(state$app, "note_count",
                 content = sprintf("[dim]%d notes[/dim]", length(notes)))
          notify(state$app, sprintf("Deleted: %s", deleted_title),
                 severity = "warning")
          update(state$app, "status_bar",
                 content = sprintf("Deleted '%s'", deleted_title))
        }
      }
    }
    state
  },

  bindings = list(
    binding("q", "quit_app", "Quit", priority = TRUE),
    binding("escape", "quit_app", "Quit", priority = TRUE),
    binding("ctrl+s", "save_note", "Save", priority = TRUE),
    binding("ctrl+n", "new_note", "New note", priority = TRUE),
    binding("d", "toggle_dark", "Dark mode", priority = TRUE)
  ),
  on_key = function(event, state) {
    if (event$key == "q" || event$key == "escape") return(quit(state))
    state
  },
  on_action = function(event, state) {
    if (event$value == "quit_app") return(quit(state))
    if (event$value == "toggle_dark") dark_toggle(state$app)
    if (event$value == "save_note") {
      # Trigger save logic
      idx <- state$get("selected_idx")
      notes <- state$get("notes")
      if (idx >= 1L && idx <= length(notes)) {
        title_val <- state$get("current_title")
        body_val <- state$get("current_body")
        if (!is.null(title_val) && nzchar(title_val)) {
          notes[[idx]]$title <- title_val
        }
        if (!is.null(body_val)) {
          notes[[idx]]$body <- body_val
        }
        notes[[idx]]$modified <- format(Sys.time(), "%Y-%m-%d %H:%M")
        state$set("notes", notes)
        save_notes(notes)
        refresh_list(state)
        notify(state$app, sprintf("Saved: %s", notes[[idx]]$title), severity = "info")
      }
    }
    if (event$value == "new_note") {
      notes <- state$get("notes")
      new_note <- list(
        id = next_id(notes),
        title = "Untitled Note",
        body = "# New Note\n\nStart writing here...\n",
        created = format(Sys.time(), "%Y-%m-%d %H:%M"),
        modified = format(Sys.time(), "%Y-%m-%d %H:%M")
      )
      notes <- c(notes, list(new_note))
      state$set("notes", notes)
      save_notes(notes)
      refresh_list(state)
      select_note(state, length(notes))
      update(state$app, "note_count",
             content = sprintf("[dim]%d notes[/dim]", length(notes)))
      notify(state$app, "New note created.", severity = "info")
    }
    state
  },

  css = paste0(
    tui_theme("catppuccin"),
    "
    #main_layout { height: 1fr; }
    #sidebar { width: 30; border-right: tall $accent; padding: 0 1; }
    #search_bar { height: 3; }
    #search_input { width: 100%; }
    #note_list { height: 1fr; }
    #sidebar_buttons { height: 3; align: center middle; }
    Button { margin: 0 1; min-width: 8; }
    #note_count { height: 1; text-align: center; color: $text-muted; }

    #main_panel { width: 1fr; padding: 0 1; }
    #title_bar { height: 3; align: left middle; }
    #title_label { width: auto; padding: 0 1; }
    #title_input { width: 1fr; }
    #btn_save { margin: 0 1; }

    #content_area { height: 1fr; }
    #editor_panel { width: 1fr; }
    #preview_panel { width: 1fr; border-left: tall $accent; padding: 0 1; }
    #editor_label, #preview_label { height: 1; text-align: center; }
    #editor { height: 1fr; }
    #preview { height: 1fr; }
    TextArea { height: 1fr; }
    MarkdownViewer { height: 1fr; }
    Markdown { height: 1fr; }

    #status_bar { height: 1; dock: bottom; padding: 0 1; }
    Rule { height: 1; margin: 0; }
    "
  )
)

message("--- Markdown Notes exited ---")
