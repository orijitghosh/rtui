# Architectural Decision Record

## Architecture: reticulate single-process bridge

**Decision**: Use reticulate to run Textual in the same process as R, rather than
a subprocess architecture with JSON/msgpack IPC.

**Rationale**: Lower latency per keypress, simpler state management, reticulate
is already a common dependency in the R data-science stack.

**Fallback**: If reticulate + asyncio proves unworkable (deadlocks, REPL freeze),
switch to subprocess architecture per PRD section 3.3.

---

## Spike results

Executed 2026-05-22 on Windows 11, R 4.4.3, Python 3.12, Textual 0.85.2, Rich 13.9.4.

### S1 — Asyncio loop on main thread
**PASS.** Textual app launched via `py_run_string("app.run()")`, auto-exited after 3.0 seconds, R regained control cleanly. No REPL freeze, no deadlock. Terminal state fully restored.

### S2 — Synchronous R callback from Python
**PASS.** Python-side timer called R callback with `{type: "test", value: 42}`. R computed 42 + 100 = 142, returned it. Python received 142 and passed it to `app.exit()`. Round-trip verified on both sides.

### S3 — Pinned install on all platforms
**PASS** (Windows). `textual==0.85.2` and `rich>=13.7,<14` (resolved to 13.9.4) installed cleanly into `r-rtui` virtualenv via reticulate. Note: must use `RETICULATE_PYTHON_ENV` (not `RETICULATE_PYTHON`) to avoid conflict with the Microsoft Store Python on Windows. The virtualenv must be created with an explicit `python=` path pointing to a non-Store Python (e.g., Python 3.12 from python.org).

### S4 — Keypress-to-callback latency
**PASS.** 20 measurements via simulated timer-driven events:
- Median: 0.50 ms
- Mean: 1.03 ms
- P95: 1.26 ms
- Min: 0.27 ms, Max: 10.93 ms

Well under the 15 ms p95 target and 50 ms ceiling (PRD §9).

---

## Python environment setup on Windows

`RETICULATE_PYTHON` env var must NOT point at the Microsoft Store Python (`WindowsApps/python.exe`) — it has DLL access restrictions. Use `RETICULATE_PYTHON_ENV = "r-rtui"` and create the virtualenv with an explicit `python=` path to a python.org install.
