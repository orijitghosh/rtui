# rtui Package — Handoff Document

## What is rtui?

An R package providing idiomatic R bindings to Python’s Textual TUI
framework via reticulate. Users write R code to define terminal UIs — no
Python needed. The full spec is in `rtui_PRD.md`.

## Architecture

Single-process model: R and Python share address space via `reticulate`.
Textual’s asyncio event loop runs on the main thread. R callbacks are
dispatched synchronously from the event loop.

    User R code → R6/spec objects → reticulate → Python shim (Textual App subclass) → Textual

## Current Status: Phase 0-5 complete, all spikes passed, full widget showcase working

### What’s been built

**Phase 0 — Scaffolding (DONE)** - `DESCRIPTION` with deps: reticulate
(\>= 1.35), R6, rlang, cli - `rtui.Rproj`, `LICENSE`, `LICENSE.md`,
`NAMESPACE` (placeholder for roxygen) - `.Rbuildignore`, `.gitignore` -
Full directory structure per PRD §7.1 - `inst/DECISIONS.md`,
`inst/DEVIATIONS.md` - `inst/python/requirements.txt` with pinned
`textual==0.85.*` and `rich>=13.7,<14`

**Phase 2 — Spec Layer (DONE)** All widget constructors implemented —
pure R, no Python dependency:

- `R/spec.R` — internal `new_spec()`, validators (`validate_id`,
  `validate_classes`, `validate_children`), `compact()`,
  `print.rtui_spec()`
- `R/widgets-containers.R` —
  [`vstack()`](https://orijitghosh.github.io/rtui/reference/vstack.md),
  [`hstack()`](https://orijitghosh.github.io/rtui/reference/hstack.md),
  [`grid()`](https://orijitghosh.github.io/rtui/reference/grid.md),
  [`container()`](https://orijitghosh.github.io/rtui/reference/container.md),
  [`scroll()`](https://orijitghosh.github.io/rtui/reference/scroll.md),
  [`center()`](https://orijitghosh.github.io/rtui/reference/center.md),
  [`middle()`](https://orijitghosh.github.io/rtui/reference/middle.md)
- `R/widgets-display.R` —
  [`text()`](https://orijitghosh.github.io/rtui/reference/text.md),
  [`box()`](https://orijitghosh.github.io/rtui/reference/box.md),
  [`static()`](https://orijitghosh.github.io/rtui/reference/static.md),
  [`log_view()`](https://orijitghosh.github.io/rtui/reference/log_view.md),
  [`markdown()`](https://orijitghosh.github.io/rtui/reference/markdown.md),
  [`progress_bar()`](https://orijitghosh.github.io/rtui/reference/progress_bar.md),
  [`sparkline()`](https://orijitghosh.github.io/rtui/reference/sparkline.md),
  [`rule()`](https://orijitghosh.github.io/rtui/reference/rule.md),
  [`loading()`](https://orijitghosh.github.io/rtui/reference/loading.md),
  [`digits()`](https://orijitghosh.github.io/rtui/reference/digits.md),
  [`placeholder()`](https://orijitghosh.github.io/rtui/reference/placeholder.md),
  [`pretty_table()`](https://orijitghosh.github.io/rtui/reference/pretty_table.md)
- `R/widgets-input.R` —
  [`input()`](https://orijitghosh.github.io/rtui/reference/input.md),
  [`button()`](https://orijitghosh.github.io/rtui/reference/button.md),
  [`list_view()`](https://orijitghosh.github.io/rtui/reference/list_view.md),
  [`data_table()`](https://orijitghosh.github.io/rtui/reference/data_table.md),
  [`checkbox()`](https://orijitghosh.github.io/rtui/reference/checkbox.md),
  [`radio_button()`](https://orijitghosh.github.io/rtui/reference/radio_button.md),
  [`radio_set()`](https://orijitghosh.github.io/rtui/reference/radio_set.md),
  [`select()`](https://orijitghosh.github.io/rtui/reference/select.md),
  [`switch_input()`](https://orijitghosh.github.io/rtui/reference/switch_input.md),
  [`text_area()`](https://orijitghosh.github.io/rtui/reference/text_area.md),
  [`option_list()`](https://orijitghosh.github.io/rtui/reference/option_list.md),
  [`selection_list()`](https://orijitghosh.github.io/rtui/reference/selection_list.md)
- `R/widgets-nav.R` —
  [`tabs()`](https://orijitghosh.github.io/rtui/reference/tabs.md),
  [`tab_pane()`](https://orijitghosh.github.io/rtui/reference/tab_pane.md),
  [`header()`](https://orijitghosh.github.io/rtui/reference/header.md),
  [`footer()`](https://orijitghosh.github.io/rtui/reference/footer.md),
  [`collapsible()`](https://orijitghosh.github.io/rtui/reference/collapsible.md),
  [`content_switcher()`](https://orijitghosh.github.io/rtui/reference/content_switcher.md),
  [`tree()`](https://orijitghosh.github.io/rtui/reference/tree.md)
- `R/state.R` —
  [`tui_state()`](https://orijitghosh.github.io/rtui/reference/tui_state.md),
  `RtuiState` R6 class with get/set/as_list/data active binding
- `R/events.R` —
  [`event_key()`](https://orijitghosh.github.io/rtui/reference/event_key.md),
  [`event_change()`](https://orijitghosh.github.io/rtui/reference/event_change.md),
  [`event_click()`](https://orijitghosh.github.io/rtui/reference/event_click.md),
  [`quit()`](https://orijitghosh.github.io/rtui/reference/quit.md)
- `R/errors.R` — error hierarchy: `rtui_error` → `rtui_spec_error`,
  `rtui_python_error`, `rtui_no_tty`, `rtui_install_error`,
  `rtui_callback_error`
- `R/terminal.R` —
  [`check_terminal()`](https://orijitghosh.github.io/rtui/reference/check_terminal.md)
  — detects dumb term, RStudio, Positron, non-tty
- `R/app.R` —
  [`tui_app()`](https://orijitghosh.github.io/rtui/reference/tui_app.md),
  `RtuiApp` R6 class (run/exit/dispatch)
- `R/update.R` —
  [`update()`](https://orijitghosh.github.io/rtui/reference/update.md),
  [`notify()`](https://orijitghosh.github.io/rtui/reference/notify.md)
- `R/bridge.R` — `load_shim()`, `as_r_event()`, `%||%`
- `R/install.R` —
  [`install_python_deps()`](https://orijitghosh.github.io/rtui/reference/install_python_deps.md)
- `R/zzz.R` — `.onLoad` lazy virtualenv activation

**Phase 3 — Python Shim (SCAFFOLDED)** -
`inst/python/rtui_shim/__init__.py` — module init -
`inst/python/rtui_shim/app.py` — `RtuiApp(App)` subclass with compose,
event handlers, apply_update, notify -
`inst/python/rtui_shim/factory.py` — `build_widget(spec)` dispatches on
kind, maps to Textual widgets - `inst/python/rtui_shim/bridge.py` —
`make_event_dict()` helper - `inst/python/rtui_shim/version.py` —
version string

**Tests (DONE — 150 pass, 1 skip)** - `tests/testthat/test-spec-build.R`
— 20+ tests covering original widget constructors, validation, nesting,
purity - `tests/testthat/test-widgets-extended.R` — 30+ tests for all
expanded widgets (checkbox, radio, select, tabs, tree, markdown,
progress_bar, sparkline, rule, etc.) - `tests/testthat/test-state.R` —
state creation, get/set, as_list, determinism -
`tests/testthat/test-events.R` — event wrappers, quit sentinel, handler
invocation - `tests/testthat/test-terminal-detect.R` — TERM=dumb,
RStudio, Positron detection (uses withr) -
`tests/testthat/test-python-roundtrip.R` — gated by skip_if_no_python,
basic shim import

**Examples** - `inst/examples/01-hello.R` — minimal hello world -
`inst/examples/02-list-detail.R` — list-detail layout -
`inst/examples/03-data-table.R` — data table viewer -
`inst/examples/04-dfdiff-explorer.R` — multi-section explorer

### What’s NOT done yet

**Phase 6 — Polish** - Vignettes (getting-started, widget-catalog,
architecture) — not started - pkgdown site — not started - Benchmark
suite — not started - NAMESPACE needs regeneration via roxygen2 - CI
setup (GitHub Actions for Linux/macOS/Windows)

### Key design decisions

1.  **Spec purity**: Widget constructors produce plain R lists with
    class `"rtui_spec"`. No Python interaction at construction time.
    This enables pure-R unit testing of the entire spec layer.

2.  **Callback contract**: `function(event, state) → state`. Returning
    `quit(result)` terminates the app. Events are plain R lists with
    fields: type, key, widget_id, value, width, height, timestamp.

3.  **State model**: R6-based mutable state (`RtuiState`) with
    get/set/as_list. The `data` active binding allows direct list
    assignment.

4.  **Error classes**: All errors use
    [`rlang::abort()`](https://rlang.r-lib.org/reference/abort.html)
    with structured classes for programmatic catching.

5.  **Base pipe only**: `|>` everywhere, no magrittr.

### How to test right now

``` r
# In R console, from the package directory:
devtools::load_all()      # load the package
devtools::test()          # run all tests

# Or specific test files:
testthat::test_file("tests/testthat/test-spec-build.R")
testthat::test_file("tests/testthat/test-state.R")
testthat::test_file("tests/testthat/test-events.R")
testthat::test_file("tests/testthat/test-terminal-detect.R")

# Check package:
devtools::check()
```

### Spike results (Phase 1 — ALL PASSED, 2026-05-22)

- **S1** (asyncio main thread): PASS — 3s auto-exit, R regained control
  cleanly
- **S2** (R callback round-trip): PASS — 42 → 142 verified on both sides
- **S3** (pinned install): PASS — textual 0.85.2, rich 13.9.4
- **S4** (latency): PASS — 0.50ms median, 1.26ms p95 (target: \<15ms
  p95)

### E2E bridge tests (Phase 4-5 — ALL PASSED)

- `spikes/test_e2e_hello.R` — basic bridge: mount, key, quit, state
  return
- `spikes/test_e2e_list_detail.R` — ListView arrow navigation, change
  events, update() detail panel
- `spikes/test_e2e_data_table.R` — DataTable widget with mtcars data
- `spikes/test_e2e_full_widgets.R` — full 20+ widget showcase: tabs,
  forms, tree, markdown, sparkline, data_table (24 events captured)

### ListView events (added during Phase 5)

Python shim emits `change` events on `ListView.Highlighted` (arrow
navigation) and `click` events on `ListView.Selected` (Enter key). Event
value is a dict with `index` (int) and `label` (str). R side accesses
via `event$value$label`.

### Windows reticulate setup

Critical: Microsoft Store Python (`WindowsApps/python.exe`) has DLL
access restrictions and MUST be avoided. Use: -
`Sys.unsetenv("RETICULATE_PYTHON")` to clear any env var pointing at
Store Python - `Sys.setenv(RETICULATE_PYTHON_ENV = "r-rtui")` to point
at the virtualenv - Create virtualenv with explicit `python=` path to
python.org install - Python 3.12 confirmed working:
`C:/Users/ariji/AppData/Local/Programs/Python/Python312/python.exe`

### Bugs fixed during Phase 5

- **Rule widget**: Textual’s `Rule()` first positional arg is
  `orientation`, not label. Fixed by rendering labeled rules as
  `Static("── label ──")` and plain rules as `Rule()`.
- **TabbedContent**: `TabbedContent(*children)` captures args as
  `*titles` (strings), not widget children. Fixed by using
  `tc.compose_add_child(child)` to add TabPanes to `_tab_content`.
- **Tree events**: `Tree.NodeHighlighted` has no `.tree` attribute.
  Fixed by accessing `event.node.tree` instead.

### Next steps for a future agent

1.  Write vignettes (getting-started, widget-catalog, architecture) —
    Phase 6
2.  Set up pkgdown site — Phase 6
3.  Write benchmark suite under `tests/benchmarks/` — Phase 6
4.  CI setup (GitHub Actions for Linux/macOS/Windows)
5.  Regenerate NAMESPACE via
    [`devtools::document()`](https://devtools.r-lib.org/reference/document.html)

### File map

    rtui/
    ├── DESCRIPTION                 # Package metadata
    ├── NAMESPACE                   # Auto-generated (roxygen)
    ├── LICENSE / LICENSE.md        # MIT
    ├── rtui.Rproj                  # RStudio project file
    ├── .Rbuildignore / .gitignore
    ├── rtui_PRD.md                 # Full product requirements
    ├── HANDOFF.md                  # This file
    ├── R/
    │   ├── app.R                   # tui_app(), RtuiApp R6 class
    │   ├── bridge.R                # reticulate bridge, load_shim(), as_r_event()
    │   ├── errors.R                # abort_* error constructors
    │   ├── events.R                # event_key/change/click(), quit()
    │   ├── install.R               # install_python_deps()
    │   ├── spec.R                  # new_spec(), validators, print method
    │   ├── state.R                 # tui_state(), RtuiState R6
    │   ├── terminal.R              # check_terminal()
    │   ├── update.R                # update(), notify()
    │   ├── widgets-containers.R    # vstack, hstack, grid, container, scroll, center, middle
    │   ├── widgets-display.R       # text, box, static, log_view, markdown, progress_bar, sparkline, rule, loading, digits, placeholder, pretty_table
    │   ├── widgets-input.R         # input, button, list_view, data_table, checkbox, radio_button, radio_set, select, switch_input, text_area, option_list, selection_list
    │   ├── widgets-nav.R           # tabs, tab_pane, header, footer, collapsible, content_switcher, tree
    │   └── zzz.R                   # .onLoad
    ├── inst/
    │   ├── DECISIONS.md            # Architecture decision record
    │   ├── DEVIATIONS.md           # PRD deviation log
    │   ├── examples/               # 4 runnable examples
    │   └── python/
    │       ├── requirements.txt    # Pinned: textual==0.85.*, rich>=13.7,<14
    │       └── rtui_shim/          # Python shim package
    │           ├── __init__.py
    │           ├── app.py          # RtuiApp(textual.app.App)
    │           ├── bridge.py       # make_event_dict()
    │           ├── factory.py      # build_widget(spec)
    │           └── version.py
    ├── tests/
    │   ├── testthat.R
    │   └── testthat/
    │       ├── test-spec-build.R   # Widget spec tests (pure R)
    │       ├── test-state.R        # State management tests
    │       ├── test-events.R       # Event/handler tests
    │       ├── test-terminal-detect.R  # TTY detection tests
    │       └── test-python-roundtrip.R # Python integration (gated)
    ├── spikes/                     # Throwaway spike scripts (Phase 1)
    ├── man/                        # Auto-generated docs
    └── vignettes/                  # Not yet written
