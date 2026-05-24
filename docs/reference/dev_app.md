# Run an app with hot reload

Watches a `.R` file for changes and automatically re-runs it when saved.
The file is sourced directly in the current R session. When the app
exits (user quits or it crashes), the file's modification time is
checked and the app re-sources if the file changed.

## Usage

``` r
dev_app(file, poll = 1)
```

## Arguments

- file:

  Path to an `.R` file that runs an rtui app.

- poll:

  Polling interval in seconds for file change detection (used when
  waiting for changes after app exit). Default `1`.

## Value

Called for its side effect (runs the app in a loop). Returns `NULL`
invisibly when interrupted.

## Details

**Workflow:** edit your `.R` file in an editor, save, then quit the
running app (e.g. press `q`) — it restarts automatically with your
changes. If the app crashes, it waits for the next file save before
restarting.

Press `Ctrl+C` when the app is **not** running (i.e. between restarts)
to stop the watcher.

`dev_app()` is designed for rapid development iteration. It:

1.  Sources and runs the given `.R` file

2.  When the app exits, checks if the file was modified

3.  If modified: re-sources immediately

4.  If not modified: polls until the file changes, then re-sources

5.  Continues until you press `Ctrl+C` between app runs

Because the file is sourced directly (not via a subprocess), the app
gets full terminal control and all keyboard/mouse input works normally.

## Examples

``` r
if (FALSE) { # \dontrun{
# In a terminal:
dev_app("my_app.R")

# Edit my_app.R in your editor, save, quit the app — it restarts
} # }
```
