# PRD: rtui — R bindings for Textual

**Version**: 0.1.0-draft **Status**: Pre-implementation specification
**Target build agent**: Claude Code (Opus 4.7, Opus 4.6 or Sonnet 4.6)
**Target environment**: R ≥ 4.2, Python ≥ 3.10, Textual ≥ 0.80
**Document type**: Agent-ready technical PRD

------------------------------------------------------------------------

## 1. Purpose

Build `rtui`, an R package providing idiomatic R bindings to Python’s
[Textual](https://textual.textualize.io) framework, enabling R users to
author full-screen terminal user interfaces (TUIs) — panels, focus
management, event loops, async workers, CSS-like styling — without
writing Python.

The package is positioned as the R-ecosystem equivalent of Textual /
Ratatui. It is **not** a pure-R reimplementation; it is a wrapper. This
is an explicit, documented architectural decision.

------------------------------------------------------------------------

## 2. Non-goals

The following are out of scope for v0.1.0 and must not be implemented:

- Pure-R rendering backend (no terminal buffer or diff renderer written
  in R).
- Mouse event handling beyond click-to-focus.
- Sixel/kitty inline graphics.
- Custom themes beyond Textual’s built-in dark/light.
- Distribution via CRAN as a binary-only package (CRAN submission
  deferred to v0.2.0).
- Windows `Rterm.exe` or RStudio integrated console support (modern
  Windows Terminal only).
- Reactive system with auto-tracking dependencies (Shiny-style). v0.1
  uses explicit state updates.

------------------------------------------------------------------------

## 3. Architecture

### 3.1 Layer diagram

    ┌─────────────────────────────────────┐
    │  User R code                        │
    │  (app definition, callbacks, state) │
    └──────────────┬──────────────────────┘
                   │ R6 / S7 objects
    ┌──────────────▼──────────────────────┐
    │  rtui R API                         │
    │  - widget constructors              │
    │  - app lifecycle                    │
    │  - event dispatch shim              │
    └──────────────┬──────────────────────┘
                   │ reticulate
    ┌──────────────▼──────────────────────┐
    │  rtui Python shim (inst/python/)    │
    │  - Textual App subclass             │
    │  - R callback marshaller            │
    │  - widget factory                   │
    └──────────────┬──────────────────────┘
                   │ Python imports
    ┌──────────────▼──────────────────────┐
    │  Textual (PyPI)                     │
    └─────────────────────────────────────┘

### 3.2 Process model

Single process. R and Python share an address space via `reticulate`.
Textual’s asyncio event loop runs on the **main thread**; R callbacks
are dispatched **synchronously** from the event loop. Long-running R
callbacks block the UI — documented limitation in v0.1, addressed in
v0.2 via `callr` worker offload.

### 3.3 Why not a separate process

A subprocess architecture (R ⇄ Python over JSON/msgpack stdio) was
considered and rejected for v0.1 on the grounds of:

- Event-loop latency (every keypress crosses a process boundary).
- Complexity of bidirectional state sync.
- `reticulate` is already a hard dependency of much of the R
  data-science stack and is mature.

Subprocess architecture is reserved as a fallback if `reticulate` proves
unworkable (e.g., asyncio integration blocks the R REPL irrecoverably).
Document this in `inst/DECISIONS.md`.

------------------------------------------------------------------------

## 4. Public R API

### 4.1 Surface area

Exactly the following symbols are exported in v0.1.0. No others.

**App lifecycle**

- `tui_app(layout, on_mount = NULL, on_key = NULL, on_quit = NULL, css = NULL)`
  → `RtuiApp`
- `RtuiApp$run()` — blocks until quit; returns final state invisibly
- `RtuiApp$exit(result = NULL)` — programmatic quit

**Layout containers**

- `vstack(..., id = NULL, classes = NULL)`
- `hstack(..., id = NULL, classes = NULL)`
- `grid(..., rows = NULL, cols = NULL, id = NULL, classes = NULL)`
- `container(..., id = NULL, classes = NULL)` — plain block

**Widgets**

- `text(content, id = NULL, classes = NULL)`
- `box(child, border = c("none", "round", "heavy", "double"), title = NULL, id = NULL, classes = NULL)`
- `input(placeholder = "", value = "", id = NULL, classes = NULL)`
- `button(label, id = NULL, classes = NULL)`
- `list_view(items, id = NULL, classes = NULL)`
- `data_table(df, id = NULL, classes = NULL)` — `df` is an R
  `data.frame`
- `static(content, id = NULL, classes = NULL)` — non-interactive rich
  text
- `log_view(id = NULL, classes = NULL, max_lines = 1000)` — append-only

**State and updates**

- `tui_state(initial)` → mutable state object (R6, environment-backed)
- `update(app, id, ...)` — mutate a widget by id; named args become
  widget properties
- `notify(app, message, severity = c("info", "warning", "error"))`

**Event helpers (used inside callbacks)**

- `event_key(handler)` — wraps a function as a key-event handler
- `event_change(handler)` — wraps a function as a change-event handler
- `event_click(handler)` — wraps a function as a click-event handler
- `quit(result = NULL)` — sentinel returned from callbacks to terminate
  the app

### 4.2 Callback contract

Every event callback receives `(event, state)` and returns `state`
(mutated or replaced). Returning `quit(result)` terminates the app.

``` r
on_key = function(event, state) {
  if (event$key == "q") return(quit(state))
  if (event$key == "j") state$cursor <- state$cursor + 1L
  state
}
```

**Event object schema** (a plain R list):

| Field | Type | Notes |
|----|----|----|
| `type` | character(1) | `"key"`, `"change"`, `"click"`, `"mount"`, `"resize"` |
| `key` | character(1) | present for `"key"` only; Textual key name (e.g. `"ctrl+c"`, `"enter"`, `"a"`) |
| `widget_id` | character(1) | id of the originating widget, or `NA` |
| `value` | any | for `"change"`: new widget value |
| `width`, `height` | integer(1) | for `"resize"` |
| `timestamp` | POSIXct | wall-clock receipt time in R |

### 4.3 Reference example

``` r
library(rtui)

app <- tui_app(
  layout = vstack(
    box(text("dfdiff explorer", id = "title"), border = "round"),
    hstack(
      list_view(items = c("schema", "rows", "meta"), id = "menu"),
      box(static("Select a section", id = "detail"), border = "round")
    ),
    id = "root"
  ),
  on_key = function(event, state) {
    if (event$key == "q") return(quit(state))
    state
  },
  on_mount = function(event, state) {
    state$started_at <- Sys.time()
    state
  }
)

app$run()
```

------------------------------------------------------------------------

## 5. Python shim specification

### 5.1 Location

`inst/python/rtui_shim/` — installed alongside the package, located at
runtime via `system.file("python", package = "rtui")`.

### 5.2 Files

    inst/python/rtui_shim/
    ├── __init__.py
    ├── app.py          # RtuiApp(textual.app.App) subclass
    ├── factory.py      # build_widget(spec: dict) -> Widget
    ├── bridge.py       # R callback invocation
    └── version.py      # __version__ pinned to R package version

### 5.3 Widget specification format

R constructors produce nested R lists; `reticulate` converts to Python
dicts. The shim’s `factory.build_widget(spec)` consumes:

``` python
{
  "kind": "vstack" | "hstack" | "box" | "text" | ...,
  "id": str | None,
  "classes": list[str] | None,
  "props": dict,        # kind-specific (border, title, items, ...)
  "children": list[spec] | None
}
```

`factory.py` dispatches on `kind` to the matching Textual widget.
Unknown `kind` raises `RtuiSpecError`.

### 5.4 R callback bridge

The shim does **not** call R directly. Instead, on each event, `RtuiApp`
posts the event onto a `queue.Queue` and awaits a result. A short-lived
synchronous handler installed on the R side (via
[`reticulate::py_run_string`](https://rstudio.github.io/reticulate/reference/py_run.html)
initialization) drains the queue, dispatches to the user’s R callback,
and pushes back the new state.

**Open risk**: this requires `reticulate` to support running an asyncio
loop on the main thread without deadlocking R’s REPL. Pre-implementation
spike required (see §11).

### 5.5 Pinning

`requirements.txt` pinned in `inst/python/`:

    textual==0.85.*
    rich>=13.7,<14

Exact version selected during the spike. Pinning is mandatory —
Textual’s API surface evolves.

------------------------------------------------------------------------

## 6. Install and runtime

### 6.1 Python environment

On first load,
`rtui::install_python_deps(envname = "r-rtui", method = "auto")` creates
a dedicated `reticulate` virtualenv and installs the pinned
requirements. Subsequent loads call
`reticulate::use_virtualenv("r-rtui", required = TRUE)`.

If the environment exists but is missing dependencies, fail loudly with
a clear remediation message. Do not silently auto-install on
[`library(rtui)`](https://github.com/orijitghosh/rtui).

### 6.2 Terminal detection

`rtui` refuses to launch and emits a structured error
(`rlang::abort(class = "rtui_no_tty")`) when:

- `isatty(stdin())` is `FALSE`
- `Sys.getenv("TERM") == "dumb"`
- Running inside RStudio (detected via `Sys.getenv("RSTUDIO") == "1"`)
- Running inside Positron’s integrated console (same detection)

Document workarounds: run from an external terminal (Windows Terminal,
iTerm2, Alacritty, GNOME Terminal, kitty).

### 6.3 Supported platforms

| Platform                       | Status               |
|--------------------------------|----------------------|
| Linux + xterm-256color         | tier 1 (CI)          |
| macOS + Terminal.app / iTerm2  | tier 1 (CI)          |
| Windows + Windows Terminal     | tier 1 (CI)          |
| Windows + ConEmu / cmder       | tier 2 (best effort) |
| Windows + `Rterm.exe` directly | unsupported          |
| RStudio / Positron consoles    | unsupported          |

------------------------------------------------------------------------

## 7. Internal structure

### 7.1 R package layout

    rtui/
    ├── DESCRIPTION
    ├── NAMESPACE                          # generated; never hand-edit
    ├── R/
    │   ├── app.R                          # tui_app, RtuiApp R6 class
    │   ├── widgets-containers.R           # vstack, hstack, grid, container
    │   ├── widgets-display.R              # text, box, static, log_view
    │   ├── widgets-input.R                # input, button, list_view, data_table
    │   ├── state.R                        # tui_state
    │   ├── events.R                       # event_* wrappers, quit()
    │   ├── bridge.R                       # reticulate setup, py shim loading
    │   ├── install.R                      # install_python_deps
    │   ├── terminal.R                     # tty detection
    │   ├── errors.R                       # rlang::abort wrappers
    │   └── zzz.R                          # .onLoad
    ├── inst/
    │   ├── python/                        # see §5
    │   ├── examples/
    │   │   ├── 01-hello.R
    │   │   ├── 02-list-detail.R
    │   │   ├── 03-data-table.R
    │   │   └── 04-dfdiff-explorer.R
    │   ├── DECISIONS.md                   # architectural decision record
    │   └── DEVIATIONS.md                  # agent-reported deviations
    ├── tests/
    │   └── testthat/
    │       ├── test-spec-build.R          # widget spec construction (no Python)
    │       ├── test-state.R
    │       ├── test-events.R
    │       ├── test-terminal-detect.R
    │       └── test-python-roundtrip.R    # gated by skip_if_no_python()
    └── vignettes/
        ├── getting-started.Rmd
        ├── widget-catalog.Rmd
        └── architecture.Rmd

### 7.2 Error class hierarchy

All errors raised via
[`rlang::abort()`](https://rlang.r-lib.org/reference/abort.html) with
class chain:

    rtui_error
    ├── rtui_spec_error          # invalid widget spec
    ├── rtui_python_error        # exception bubbled from Python
    ├── rtui_no_tty              # environment unsupported
    ├── rtui_install_error       # python env setup failed
    └── rtui_callback_error      # user callback threw

User-facing messages must include remediation. Internal traces preserved
via `parent` argument.

------------------------------------------------------------------------

## 8. Algorithms

### 8.1 Widget spec construction (R side)

Each widget constructor:

1.  Validates arguments
    ([`rlang::arg_match`](https://rlang.r-lib.org/reference/arg_match.html),
    type checks).
2.  Constructs a list with fields `kind`, `id`, `classes`, `props`,
    `children`.
3.  Assigns class `c("rtui_spec", "list")` for dispatch.
4.  Returns. **No Python interaction at construction time.**

This permits unit testing the entire spec layer without a Python
runtime.

### 8.2 App run loop

    tui_app$run():
      1. Ensure Python env ready (§6.1)
      2. Validate terminal (§6.2); abort if unsupported
      3. py_shim <- reticulate::import_from_path("rtui_shim", inst_python_path)
      4. spec <- self$layout
      5. py_app <- py_shim$app$RtuiApp$new(spec, callback_dispatcher = self$_dispatch)
      6. py_app$run()                       # blocks; Textual takes over terminal
      7. on Python exit: restore terminal, return self$state invisibly

### 8.3 Event dispatch

    _dispatch(event_dict):
      event <- as_r_event(event_dict)       # py dict -> R list
      handler <- self$handlers[[event$type]]
      if (is.null(handler)) return(self$state)
      result <- withCallingHandlers(
        handler(event, self$state),
        error = function(e) abort(class = "rtui_callback_error", parent = e)
      )
      if (inherits(result, "rtui_quit")) {
        self$_exit_requested <- TRUE
        self$_exit_result <- attr(result, "result")
        return(self$state)
      }
      self$state <- result
      self$state

### 8.4 Update propagation

`update(app, id, ...)` constructs a partial spec patch and calls
`py_app$apply_update(id, patch)`. The Python shim looks up the widget by
id and assigns recognized properties. Unknown properties raise
`RtuiSpecError`.

No diffing of full layouts in v0.1 — only explicit
[`update()`](reference/update.md) calls cause re-render. Textual handles
its own internal diff/repaint.

------------------------------------------------------------------------

## 9. Performance targets

| Scenario | Target | Hard ceiling |
|----|----|----|
| Cold app start ([`library(rtui)`](https://github.com/orijitghosh/rtui) to first paint) | ≤ 2.0 s | 4.0 s |
| Keypress to handler invocation (in-R latency) | ≤ 15 ms p95 | 50 ms p95 |
| [`update()`](reference/update.md) to repaint | ≤ 30 ms p95 | 100 ms p95 |
| `data_table` initial render, 10k rows × 20 cols | ≤ 1.5 s | 3.0 s |
| Memory overhead at idle (1 app, 10 widgets) | ≤ 80 MB RSS | 150 MB RSS |

Benchmark suite in `tests/benchmarks/` (excluded from CRAN check). Run
on Linux CI; report in `inst/BENCHMARKS.md`.

------------------------------------------------------------------------

## 10. Quality invariants

Stated as properties the test suite must verify:

1.  **Spec-purity**: every widget constructor produces an identical spec
    for identical args, with no Python loaded.
2.  **Spec-validity**: every spec produced by a constructor passes
    `factory.build_widget` without error.
3.  **State-determinism**: given identical event sequences from a fixed
    initial state, final state is identical across runs.
4.  **No-leak**: after `app$run()` returns, no Python objects from the
    app remain reachable from R; terminal is restored to pre-launch
    state (cursor visible, alt-screen exited, raw mode off).
5.  **Error-bridging**: every Python exception surfaces as an
    `rtui_python_error` with the Python traceback in
    `$python_traceback`.

------------------------------------------------------------------------

## 11. Pre-implementation spikes

The agent must complete these spikes **before** beginning §12
implementation. Each spike is a throwaway script committed under
`spikes/` and a one-paragraph result in `inst/DECISIONS.md`.

| \# | Question | Success criterion |
|----|----|----|
| S1 | Can Textual’s asyncio loop run on the main thread without freezing R’s REPL on exit? | Launch a 5-second auto-exit Textual app from R via reticulate; R returns control cleanly. |
| S2 | Can a Python-side asyncio handler synchronously invoke an R callback and receive a return value? | Round-trip an integer through a key event handler, verified by R-side assertion. |
| S3 | Does pinning `textual==0.85.*` install cleanly on Linux/macOS/Windows under reticulate? | [`install_python_deps()`](reference/install_python_deps.md) succeeds on all three CI runners. |
| S4 | What is observed keypress→callback latency in the chosen architecture? | Measured median latency reported; informs §9 ceilings. |

**If S1 or S2 fails**, escalate to subprocess architecture (§3.3);
revise this PRD as v0.2-draft before continuing.

------------------------------------------------------------------------

## 12. Implementation phases

Each phase ends with a tagged commit, passing tests, and a green CI run.

### Phase 0 — Scaffolding

- `usethis::create_package("rtui")`
- DESCRIPTION with deps: `reticulate (>= 1.35)`, `R6`, `rlang`, `cli`,
  `vctrs`
- License, README skeleton, GitHub Actions workflow (lint, R CMD check,
  tests on Linux/macOS/Windows)
- `inst/DECISIONS.md`, `inst/DEVIATIONS.md` created empty

### Phase 1 — Spikes (§11)

Block on results before continuing.

### Phase 2 — Spec layer

- All widget constructors with full argument validation
- `tui_state`
- `events.R`, [`quit()`](reference/quit.md)
- 100% test coverage on `R/widgets-*.R`, `R/state.R`, `R/events.R`
  (verified by `covr`)
- No reticulate calls anywhere in this phase

### Phase 3 — Python shim

- `inst/python/rtui_shim/` with `RtuiApp`, `factory.py`, `bridge.py`
- Python-side unit tests under `inst/python/tests/` runnable via
  `pytest`
- Factory handles every widget kind from Phase 2

### Phase 4 — Bridge

- [`install_python_deps()`](reference/install_python_deps.md)
- `.onLoad` lazy-imports the shim
- `RtuiApp$run()` end-to-end with `on_mount`, `on_key`,
  [`quit()`](reference/quit.md)
- Examples 01–02 working manually

### Phase 5 — Updates and remaining widgets

- [`update()`](reference/update.md), [`notify()`](reference/notify.md)
- `data_table`, `log_view`
- Examples 03–04 working

### Phase 6 — Polish

- Vignettes
- `pkgdown` site
- Benchmark report
- Acceptance criteria (§13) verified

------------------------------------------------------------------------

## 13. Acceptance criteria for 0.1.0

All must hold:

`R CMD check --as-cran` passes on Linux, macOS, Windows with 0 errors, 0
warnings, ≤ 1 note (the note may concern Python dependency declaration).

All four spikes (§11) documented in `inst/DECISIONS.md` with outcome.

Test coverage ≥ 85% on R code (excluding `bridge.R`, which is
integration-tested).

All four examples in `inst/examples/` runnable end-to-end on tier-1
platforms.

All five invariants (§10) have at least one passing test.

Performance targets (§9) met on Linux CI; ceilings met on all tier-1.

`pkgdown` site builds without warnings.

`inst/DEVIATIONS.md` is either empty or every deviation is justified
with a rationale and a follow-up issue link.

------------------------------------------------------------------------

## 14. Agent constraints

These constraints bind the build agent across the entire engagement.

1.  **Base pipe only.** Use `|>`. Do not import `magrittr`. Do not write
    `%>%` anywhere.
2.  **No hand-editing generated files.** `NAMESPACE`, `man/*.Rd`,
    `pkgdown` site outputs are regenerated, not edited. Roxygen blocks
    are the source of truth.
3.  **No silent deviations.** Any departure from this PRD — added
    function, dropped argument, alternate algorithm, version bump — is
    recorded in `inst/DEVIATIONS.md` with: section number deviated from,
    what changed, why, and proposed follow-up.
4.  **[`rlang::abort()`](https://rlang.r-lib.org/reference/abort.html)
    for all errors.** No [`stop()`](https://rdrr.io/r/base/stop.html),
    no [`warning()`](https://rdrr.io/r/base/warning.html) for control
    flow. Use
    [`cli::cli_inform`](https://cli.r-lib.org/reference/cli_abort.html)
    for informational messages.
5.  **No new top-level dependencies** beyond those listed in Phase 0
    without recording in `inst/DEVIATIONS.md`.
6.  **Tests before integration.** Phase 2 spec-layer tests must pass
    before any Python code is written.
7.  **Pinned Python deps.** Do not loosen the pin in
    `inst/python/requirements.txt` without a deviation entry.
8.  **No mocking the bridge in unit tests.** Spec-layer tests must not
    import reticulate. Bridge tests must use the real shim.
9.  **Reproducible installs.**
    [`install_python_deps()`](reference/install_python_deps.md) must
    produce identical environments across runs given identical R and
    Python interpreter versions. No floating dependencies.
10. **Public API freeze after Phase 2.** §4.1 surface is final.
    Additions require a PRD revision.

------------------------------------------------------------------------

## 15. Open questions for human review

Resolve before Phase 2.

1.  **State model**: explicit `state` arg threaded through callbacks
    (current spec) vs. R6 mutable object vs. `reactiveVal`-style.
    Decision affects every callback signature.
2.  **`data_table` editability**: read-only in v0.1, or in-cell edit?
    Editability triples scope.
3.  **Async R workers**: defer to v0.2 (current spec) or include a
    minimal `tui_worker(fn, on_done)` in v0.1?
4.  **CSS surface**: expose Textual’s CSS as a raw string via `css =`
    (current spec), or build an R DSL? DSL is large; string is leaky.
5.  **Naming**: `tui_app` and `tui_state` vs. `rtui_app` / `rtui_state`
    vs. `app()` / `state()`. Affects every example and the API
    memorability.

------------------------------------------------------------------------

## 16. Reference analogues

- **Textual** (Python) — primary upstream dependency.
  <https://textual.textualize.io>
- **Ratatui** (Rust) — architectural inspiration for widget tree + diff
  renderer; not used directly.
- **Shiny** (R) — precedent for R-as-frontend over a separate runtime;
  precedent for declarative UI builders.
- **reticulate** (R) — bridge mechanism.
  <https://rstudio.github.io/reticulate/>

URLs above are stated from general knowledge and have not been verified
via `web_fetch` in this drafting session. The implementing agent must
confirm them before publishing user-facing documentation.
