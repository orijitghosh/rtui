# Example 14: Hot Reload Development
#
# Demonstrates: dev_app() for automatic restart on file save.
#
# dev_app() sources your .R file, and when you quit the app, it checks
# if the file changed. If it did, it re-sources automatically.
#
# Usage:
#   1. Run this script:
#      Rscript inst/examples/14-dev-reload.R
#
#   2. The app starts. Press 'q' to quit.
#
#   3. Open the temp file (path printed below) in an editor,
#      change something, save. The app restarts with your changes.
#
#   4. Press Ctrl+C between app runs to stop the watcher.
#
# In practice, you'd use dev_app() during development:
#   Rscript -e "library(rtui); dev_app('my_app.R')"

if (!requireNamespace("rtui", quietly = TRUE)) {
  devtools::load_all()
} else {
  library(rtui)
}

# Create a simple app file to watch
app_file <- tempfile(fileext = ".R")
writeLines('
if (!requireNamespace("rtui", quietly = TRUE)) {
  devtools::load_all()
} else {
  library(rtui)
}

quick_app(
  title = "Dev App",
  dark = TRUE,
  layout = vstack(
    header(),
    center(middle(vstack(
      static("[bold]Hello from dev mode![/bold]", id = "msg"),
      static(paste("Started at:", Sys.time()), id = "time"),
      button("Quit", id = "quit_btn")
    ))),
    footer()
  ),
  on_click = list(
    quit_btn = function(event, state) quit(state)
  ),
  bindings = list(
    binding("q", "quit_app", "Quit"),
    binding("d", "toggle_dark", "Dark mode")
  ),
  on_action = function(event, state) {
    if (event$value == "quit_app") return(quit(state))
    if (event$value == "toggle_dark") dark_toggle(state$app)
    state
  }
)
', app_file)

cat("Temp app file:", app_file, "\n")
cat("Edit that file and save to see hot reload.\n\n")

dev_app(app_file)
