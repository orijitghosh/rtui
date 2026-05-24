# Showcase: Git Repository Dashboard
#
# Browse git log, view diffs, see file stats, and branch info —
# all from the terminal. Works on any git repo.
#
# Run from a REAL TERMINAL (inside a git repo):
#   & "C:\Program Files\R\R-4.4.3\bin\Rscript.exe" spikes/showcase_git_dashboard.R

Sys.unsetenv("RETICULATE_PYTHON")
Sys.setenv(RETICULATE_PYTHON_ENV = "r-rtui")

library(reticulate)
use_virtualenv("r-rtui", required = TRUE)

devtools::load_all(".")

message("--- Git Dashboard ---")
message("Browse commits, view diffs, and repo stats.")
message("Press q to quit.")

# --- Git helpers (call git via system()) ---
git_cmd <- function(args) {
  result <- suppressWarnings(
    system2("git", args, stdout = TRUE, stderr = TRUE)
  )
  if (!is.null(attr(result, "status")) && attr(result, "status") != 0) {
    return(NULL)
  }
  result
}

get_branch <- function() {
  b <- git_cmd(c("rev-parse", "--abbrev-ref", "HEAD"))
  if (is.null(b)) "unknown" else trimws(b[1])
}

get_branches <- function() {
  b <- git_cmd(c("branch", "--format=%(refname:short)"))
  if (is.null(b)) character(0) else trimws(b)
}

get_repo_name <- function() {
  r <- git_cmd(c("rev-parse", "--show-toplevel"))
  if (is.null(r)) "unknown" else basename(trimws(r[1]))
}

get_status <- function() {
  s <- git_cmd(c("status", "--short"))
  if (is.null(s)) character(0) else s
}

get_log <- function(n = 30L) {
  fmt <- "--format=%H|%h|%an|%ar|%s"
  lines <- git_cmd(c("log", fmt, sprintf("-n%d", n)))
  if (is.null(lines) || length(lines) == 0) return(NULL)

  parts <- strsplit(lines, "\\|", fixed = FALSE)
  data.frame(
    Hash    = vapply(parts, `[`, character(1), 2),
    Author  = vapply(parts, `[`, character(1), 3),
    Date    = vapply(parts, `[`, character(1), 4),
    Message = vapply(parts, function(p) paste(p[5:length(p)], collapse = "|"), character(1)),
    stringsAsFactors = FALSE
  )
}

get_diff_stat <- function() {
  d <- git_cmd(c("diff", "--stat", "HEAD"))
  if (is.null(d)) "No changes" else paste(d, collapse = "\n")
}

get_file_counts <- function() {
  tracked <- git_cmd(c("ls-files"))
  n <- if (is.null(tracked)) 0L else length(tracked)
  # Count by extension
  if (n > 0) {
    exts <- tools::file_ext(tracked)
    exts[exts == ""] <- "(none)"
    counts <- sort(table(exts), decreasing = TRUE)
    top <- head(counts, 10)
    list(total = n, top = top)
  } else {
    list(total = 0, top = table(character(0)))
  }
}

get_contributors <- function(n = 10L) {
  lines <- git_cmd(c("shortlog", "-sn", "--all", sprintf("--max-count=%d", n * 10L)))
  if (is.null(lines) || length(lines) == 0) return(NULL)
  parts <- trimws(lines)
  parts <- parts[nzchar(parts)]
  parsed <- regmatches(parts, regexec("^\\s*(\\d+)\\s+(.+)$", parts))
  if (length(parsed) == 0) return(NULL)
  data.frame(
    Commits = as.integer(vapply(parsed, `[`, character(1), 2)),
    Author  = vapply(parsed, `[`, character(1), 3),
    stringsAsFactors = FALSE
  )[seq_len(min(n, length(parsed))), ]
}

# --- Build the app ---
quick_app(
  title = "Git Dashboard",
  dark = TRUE,

  layout = vstack(
    header(),

    # Repo info bar
    hstack(
      static("Repo: ...", id = "repo_name"),
      static("Branch: ...", id = "branch_name"),
      static("Files: ...", id = "file_count"),
      id = "repo_bar"
    ),

    # Main content
    tabs(
      # Log tab
      tab_pane(
        data_table(
          data.frame(Hash = character(0), Author = character(0),
                     Date = character(0), Message = character(0)),
          id = "log_table", cursor = "row", zebra_stripes = TRUE, sortable = TRUE
        ),
        title = "Log", id = "tab_log"
      ),

      # Status tab
      tab_pane(
        log_view(id = "status_log", max_lines = 200L),
        title = "Status", id = "tab_status"
      ),

      # Stats tab
      tab_pane(
        vstack(
          text_plot(id = "stats_chart"),
          id = "stats_panel"
        ),
        title = "Stats", id = "tab_stats"
      ),

      # Contributors tab
      tab_pane(
        vstack(
          text_plot(id = "contrib_chart"),
          id = "contrib_panel"
        ),
        title = "Contributors", id = "tab_contrib"
      ),

      id = "main_tabs"
    ),

    # Status bar
    static("Loading repository data...", id = "status_bar"),

    footer(),
    id = "root"
  ),

  on_mount = function(event, state) {
    # Defer loading so UI appears first
    set_timer(state$app, 0.1, "load_repo")
    state
  },

  on_timer = function(event, state) {
    if (event$timer_id == "load_repo") {
      tryCatch({
        # Repo info
        repo <- get_repo_name()
        branch <- get_branch()
        fc <- get_file_counts()
        update(state$app, "repo_name",
               content = sprintf("[bold]Repo:[/bold] %s", repo))
        update(state$app, "branch_name",
               content = sprintf("[bold cyan]Branch:[/bold cyan] %s", branch))
        update(state$app, "file_count",
               content = sprintf("[bold green]Files:[/bold green] %d", fc$total))

        # Git log
        log_df <- get_log(40L)
        if (!is.null(log_df) && nrow(log_df) > 0) {
          update(state$app, "log_table", clear_data = TRUE)
          update(state$app, "log_table", add_rows = as.list(log_df))
        }

        # Status
        status <- get_status()
        if (length(status) > 0) {
          for (line in status) {
            color <- if (grepl("^\\?\\?", line)) "yellow"
                     else if (grepl("^ M|^M", line)) "cyan"
                     else if (grepl("^ D|^D", line)) "red"
                     else if (grepl("^A", line)) "green"
                     else "white"
            log_write(state$app, "status_log",
                      sprintf("[%s]%s[/%s]", color, line, color),
                      markup = TRUE)
          }
        } else {
          log_write(state$app, "status_log", "Working tree clean.")
        }

        # Diff stat
        diff_stat <- get_diff_stat()
        log_write(state$app, "status_log", "")
        log_write(state$app, "status_log",
                  sprintf("[bold]--- Diff vs HEAD ---[/bold]"),
                  markup = TRUE)
        for (line in strsplit(diff_stat, "\n")[[1]]) {
          log_write(state$app, "status_log", line)
        }

        # File type stats chart
        if (length(fc$top) > 0) {
          labels <- names(fc$top)
          values <- as.numeric(fc$top)
          n <- min(10, length(labels))
          plot_bar(state$app, "stats_chart",
                   labels = labels[1:n], values = values[1:n],
                   title = "File Types (top 10)",
                   color = "cyan", ylabel = "Count")
        }

        # Contributors chart
        contribs <- get_contributors(10L)
        if (!is.null(contribs) && nrow(contribs) > 0) {
          plot_bar(state$app, "contrib_chart",
                   labels = contribs$Author,
                   values = contribs$Commits,
                   title = "Top Contributors",
                   color = "green", ylabel = "Commits")
        }

        update(state$app, "status_bar",
               content = sprintf("%s | %s | %d files | %d commits shown",
                                 repo, branch, fc$total,
                                 if (!is.null(log_df)) nrow(log_df) else 0L))
      }, error = function(e) {
        notify(state$app, paste("Error:", conditionMessage(e)), severity = "error")
        update(state$app, "status_bar", content = "Error loading repo data")
      })
    }
    state
  },

  bindings = list(
    binding("q", "quit_app", "Quit", priority = TRUE),
    binding("escape", "quit_app", "Quit", priority = TRUE),
    binding("r", "refresh", "Refresh", priority = TRUE),
    binding("d", "toggle_dark", "Dark mode", priority = TRUE)
  ),
  on_key = function(event, state) {
    if (event$key == "q" || event$key == "escape") return(quit(state))
    state
  },
  on_action = function(event, state) {
    if (event$value == "quit_app") return(quit(state))
    if (event$value == "toggle_dark") dark_toggle(state$app)
    if (event$value == "refresh") set_timer(state$app, 0.1, "load_repo")
    state
  },

  css = paste0(
    tui_theme("gruvbox"),
    "
    #repo_bar { height: 2; padding: 0 1; align: left middle; }
    #repo_name, #branch_name, #file_count { width: auto; padding: 0 2; }
    #log_table { height: 1fr; }
    #status_log { height: 1fr; }
    #stats_chart { height: 1fr; }
    #contrib_chart { height: 1fr; }
    #status_bar { height: 1; dock: bottom; padding: 0 1; }
    DataTable { height: 1fr; }
    "
  )
)

message("--- Git Dashboard exited ---")
