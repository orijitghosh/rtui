#' Get a built-in theme CSS string
#'
#' Returns a Textual CSS string that styles the app with a named colour theme.
#' Pass the result to the `css` parameter of [tui_app()] or [quick_app()],
#' or append it to your own CSS.
#'
#' @param name Theme name. One of: `"dracula"`, `"nord"`, `"monokai"`,
#'   `"solarized_dark"`, `"solarized_light"`, `"gruvbox"`, `"catppuccin"`,
#'   `"ocean"`, `"forest"`, `"sunset"`.
#' @return A single CSS string.
#'
#' @examples
#' \dontrun{
#' quick_app(
#'   layout = vstack(header(), text("Hello!"), footer(), id = "root"),
#'   css = tui_theme("dracula")
#' )
#' }
#'
#' @export
tui_theme <- function(name = c("dracula", "nord", "monokai",
                                "solarized_dark", "solarized_light",
                                "gruvbox", "catppuccin",
                                "ocean", "forest", "sunset")) {
  name <- rlang::arg_match(name)
  .themes[[name]]
}

#' List available theme names
#'
#' @return A character vector of theme names.
#' @export
list_themes <- function() {
  names(.themes)
}

# ---- Theme definitions ----
# Each theme sets Screen/app-level colours using Textual CSS variables
# and common widget overrides.

.themes <- list(
  dracula = "
    Screen {
      background: #282a36;
      color: #f8f8f2;
    }
    Header { background: #6272a4; color: #f8f8f2; }
    Footer { background: #44475a; color: #f8f8f2; }
    Button { background: #6272a4; color: #f8f8f2; }
    Button:hover { background: #bd93f9; }
    Input { border: tall #6272a4; }
    Input:focus { border: tall #bd93f9; }
    DataTable > .datatable--header { background: #44475a; color: #bd93f9; }
    ProgressBar Bar > .bar--bar { color: #50fa7b; }
    Static.dlg-title { color: #bd93f9; }
  ",

  nord = "
    Screen {
      background: #2e3440;
      color: #d8dee9;
    }
    Header { background: #3b4252; color: #88c0d0; }
    Footer { background: #3b4252; color: #d8dee9; }
    Button { background: #5e81ac; color: #eceff4; }
    Button:hover { background: #81a1c1; }
    Input { border: tall #4c566a; }
    Input:focus { border: tall #88c0d0; }
    DataTable > .datatable--header { background: #3b4252; color: #88c0d0; }
    ProgressBar Bar > .bar--bar { color: #a3be8c; }
    Static.dlg-title { color: #88c0d0; }
  ",

  monokai = "
    Screen {
      background: #272822;
      color: #f8f8f2;
    }
    Header { background: #3e3d32; color: #f92672; }
    Footer { background: #3e3d32; color: #a6e22e; }
    Button { background: #49483e; color: #f8f8f2; }
    Button:hover { background: #f92672; color: #f8f8f2; }
    Input { border: tall #75715e; }
    Input:focus { border: tall #e6db74; }
    DataTable > .datatable--header { background: #3e3d32; color: #66d9ef; }
    ProgressBar Bar > .bar--bar { color: #a6e22e; }
    Static.dlg-title { color: #f92672; }
  ",

  solarized_dark = "
    Screen {
      background: #002b36;
      color: #839496;
    }
    Header { background: #073642; color: #268bd2; }
    Footer { background: #073642; color: #839496; }
    Button { background: #073642; color: #93a1a1; }
    Button:hover { background: #268bd2; color: #fdf6e3; }
    Input { border: tall #586e75; }
    Input:focus { border: tall #268bd2; }
    DataTable > .datatable--header { background: #073642; color: #2aa198; }
    ProgressBar Bar > .bar--bar { color: #859900; }
    Static.dlg-title { color: #268bd2; }
  ",

  solarized_light = "
    Screen {
      background: #fdf6e3;
      color: #657b83;
    }
    Header { background: #eee8d5; color: #268bd2; }
    Footer { background: #eee8d5; color: #657b83; }
    Button { background: #eee8d5; color: #586e75; }
    Button:hover { background: #268bd2; color: #fdf6e3; }
    Input { border: tall #93a1a1; }
    Input:focus { border: tall #268bd2; }
    DataTable > .datatable--header { background: #eee8d5; color: #2aa198; }
    ProgressBar Bar > .bar--bar { color: #859900; }
    Static.dlg-title { color: #268bd2; }
  ",

  gruvbox = "
    Screen {
      background: #282828;
      color: #ebdbb2;
    }
    Header { background: #3c3836; color: #fe8019; }
    Footer { background: #3c3836; color: #ebdbb2; }
    Button { background: #504945; color: #ebdbb2; }
    Button:hover { background: #fe8019; color: #282828; }
    Input { border: tall #665c54; }
    Input:focus { border: tall #fabd2f; }
    DataTable > .datatable--header { background: #3c3836; color: #b8bb26; }
    ProgressBar Bar > .bar--bar { color: #b8bb26; }
    Static.dlg-title { color: #fe8019; }
  ",

  catppuccin = "
    Screen {
      background: #1e1e2e;
      color: #cdd6f4;
    }
    Header { background: #313244; color: #cba6f7; }
    Footer { background: #313244; color: #cdd6f4; }
    Button { background: #45475a; color: #cdd6f4; }
    Button:hover { background: #cba6f7; color: #1e1e2e; }
    Input { border: tall #585b70; }
    Input:focus { border: tall #89b4fa; }
    DataTable > .datatable--header { background: #313244; color: #89b4fa; }
    ProgressBar Bar > .bar--bar { color: #a6e3a1; }
    Static.dlg-title { color: #cba6f7; }
  ",

  ocean = "
    Screen {
      background: #0a1628;
      color: #c0d6e4;
    }
    Header { background: #112240; color: #64ffda; }
    Footer { background: #112240; color: #8892b0; }
    Button { background: #1d3461; color: #ccd6f6; }
    Button:hover { background: #64ffda; color: #0a1628; }
    Input { border: tall #233554; }
    Input:focus { border: tall #64ffda; }
    DataTable > .datatable--header { background: #112240; color: #64ffda; }
    ProgressBar Bar > .bar--bar { color: #64ffda; }
    Static.dlg-title { color: #64ffda; }
  ",

  forest = "
    Screen {
      background: #1b2a1b;
      color: #c8d6c8;
    }
    Header { background: #2d4a2d; color: #8fbc8f; }
    Footer { background: #2d4a2d; color: #c8d6c8; }
    Button { background: #3a5f3a; color: #e0efe0; }
    Button:hover { background: #8fbc8f; color: #1b2a1b; }
    Input { border: tall #4a7a4a; }
    Input:focus { border: tall #8fbc8f; }
    DataTable > .datatable--header { background: #2d4a2d; color: #8fbc8f; }
    ProgressBar Bar > .bar--bar { color: #90ee90; }
    Static.dlg-title { color: #8fbc8f; }
  ",

  sunset = "
    Screen {
      background: #1a1a2e;
      color: #e0d6cc;
    }
    Header { background: #16213e; color: #e94560; }
    Footer { background: #16213e; color: #e0d6cc; }
    Button { background: #0f3460; color: #e0d6cc; }
    Button:hover { background: #e94560; color: #1a1a2e; }
    Input { border: tall #533483; }
    Input:focus { border: tall #e94560; }
    DataTable > .datatable--header { background: #16213e; color: #e94560; }
    ProgressBar Bar > .bar--bar { color: #e94560; }
    Static.dlg-title { color: #e94560; }
  "
)
