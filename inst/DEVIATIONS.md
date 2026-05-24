# Deviations from PRD

## D1: Expanded widget set beyond §4.1

**PRD section**: §4.1 (Public R API — Widgets)

**What changed**: Added 20+ widgets beyond the v0.1.0 spec:

- **Form inputs**: `checkbox`, `radio_button`, `radio_set`, `select`, `switch_input`,
  `text_area`, `option_list`, `selection_list`
- **Navigation**: `tabs`, `tab_pane`, `header`, `footer`, `collapsible`,
  `content_switcher`, `tree`
- **Display**: `markdown`, `progress_bar`, `sparkline`, `rule`, `loading`,
  `digits`, `placeholder`, `pretty_table`
- **Containers**: `scroll`, `center`, `middle`

**Why**: User requested full Textual widget coverage rather than the minimal v0.1.0 surface.

**Follow-up**: Update PRD to reflect expanded API surface for v0.1.0.

## D2: `switch_input` naming

**PRD section**: N/A (new widget)

**What changed**: Named `switch_input()` instead of `switch()` to avoid masking
`base::switch()`.

**Why**: `switch` is a core R function; masking it would cause user confusion.

**Follow-up**: None needed.

## D3: `notify` Python method renamed to `send_notify`

**PRD section**: §4.1 (notify)

**What changed**: Python-side method renamed from `notify()` to `send_notify()`
to avoid shadowing Textual's built-in `App.notify()`.

**Why**: Method name collision caused incorrect dispatch.

**Follow-up**: None needed; R-side API is unchanged.
