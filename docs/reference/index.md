# Package index

## App lifecycle

Create and run TUI applications.

- [`tui_app()`](https://orijitghosh.github.io/rtui/reference/tui_app.md)
  : Create a TUI application
- [`quick_app()`](https://orijitghosh.github.io/rtui/reference/quick_app.md)
  : Run a TUI app in one call
- [`quit()`](https://orijitghosh.github.io/rtui/reference/quit.md) :
  Signal app termination from a callback

## Convenience apps

One-call apps for common tasks.

- [`data_viewer()`](https://orijitghosh.github.io/rtui/reference/data_viewer.md)
  : Interactive data viewer
- [`browse_files()`](https://orijitghosh.github.io/rtui/reference/browse_files.md)
  : Interactive file browser

## Layout containers

Arrange widgets spatially.

- [`vstack()`](https://orijitghosh.github.io/rtui/reference/vstack.md) :
  Create a vertical stack layout
- [`hstack()`](https://orijitghosh.github.io/rtui/reference/hstack.md) :
  Create a horizontal stack layout
- [`grid()`](https://orijitghosh.github.io/rtui/reference/grid.md) :
  Create a grid layout
- [`center()`](https://orijitghosh.github.io/rtui/reference/center.md) :
  Create a center-aligned container
- [`middle()`](https://orijitghosh.github.io/rtui/reference/middle.md) :
  Create a middle-aligned container (vertical centering)
- [`scroll()`](https://orijitghosh.github.io/rtui/reference/scroll.md) :
  Create a scrollable container
- [`container()`](https://orijitghosh.github.io/rtui/reference/container.md)
  : Create a plain block container
- [`box()`](https://orijitghosh.github.io/rtui/reference/box.md) :
  Create a box widget with optional border

## Navigation widgets

Tabs, headers, footers, collapsibles, and trees.

- [`header()`](https://orijitghosh.github.io/rtui/reference/header.md) :
  Create a header widget
- [`footer()`](https://orijitghosh.github.io/rtui/reference/footer.md) :
  Create a footer widget
- [`tabs()`](https://orijitghosh.github.io/rtui/reference/tabs.md) :
  Create a tabbed pane container
- [`tab_pane()`](https://orijitghosh.github.io/rtui/reference/tab_pane.md)
  : Create a single tab pane
- [`collapsible()`](https://orijitghosh.github.io/rtui/reference/collapsible.md)
  : Create a collapsible section
- [`content_switcher()`](https://orijitghosh.github.io/rtui/reference/content_switcher.md)
  : Create a content switcher (shows one child at a time)
- [`tree()`](https://orijitghosh.github.io/rtui/reference/tree.md) :
  Create a tree widget
- [`directory_tree()`](https://orijitghosh.github.io/rtui/reference/directory_tree.md)
  : Create a directory tree widget

## Display widgets

Show text, data, and visual indicators.

- [`text()`](https://orijitghosh.github.io/rtui/reference/text.md) :
  Create a text widget
- [`static()`](https://orijitghosh.github.io/rtui/reference/static.md) :
  Create a static rich text widget
- [`markdown()`](https://orijitghosh.github.io/rtui/reference/markdown.md)
  : Create a markdown display widget
- [`digits()`](https://orijitghosh.github.io/rtui/reference/digits.md) :
  Create a large digits display widget
- [`pretty_table()`](https://orijitghosh.github.io/rtui/reference/pretty_table.md)
  : Create a pretty table widget (rich-formatted)
- [`sparkline()`](https://orijitghosh.github.io/rtui/reference/sparkline.md)
  : Create a sparkline widget
- [`progress_bar()`](https://orijitghosh.github.io/rtui/reference/progress_bar.md)
  : Create a progress bar widget
- [`rule()`](https://orijitghosh.github.io/rtui/reference/rule.md) :
  Create a horizontal rule (divider) widget
- [`loading()`](https://orijitghosh.github.io/rtui/reference/loading.md)
  : Create a loading indicator widget
- [`placeholder()`](https://orijitghosh.github.io/rtui/reference/placeholder.md)
  : Create a placeholder widget
- [`log_view()`](https://orijitghosh.github.io/rtui/reference/log_view.md)
  : Create an append-only log view widget

## Input widgets

Buttons, text fields, selects, and lists.

- [`button()`](https://orijitghosh.github.io/rtui/reference/button.md) :
  Create a button widget
- [`input()`](https://orijitghosh.github.io/rtui/reference/input.md) :
  Create a text input widget
- [`text_area()`](https://orijitghosh.github.io/rtui/reference/text_area.md)
  : Create a multi-line text area widget
- [`masked_input()`](https://orijitghosh.github.io/rtui/reference/masked_input.md)
  : Create a masked input widget
- [`checkbox()`](https://orijitghosh.github.io/rtui/reference/checkbox.md)
  : Create a checkbox widget
- [`switch_input()`](https://orijitghosh.github.io/rtui/reference/switch_input.md)
  : Create a switch (toggle) widget
- [`select()`](https://orijitghosh.github.io/rtui/reference/select.md) :
  Create a select dropdown widget
- [`radio_set()`](https://orijitghosh.github.io/rtui/reference/radio_set.md)
  : Create a radio set (group of radio buttons)
- [`radio_button()`](https://orijitghosh.github.io/rtui/reference/radio_button.md)
  : Create a radio button widget (use inside radio_set)
- [`data_table()`](https://orijitghosh.github.io/rtui/reference/data_table.md)
  : Create a data table widget
- [`option_list()`](https://orijitghosh.github.io/rtui/reference/option_list.md)
  : Create an option list widget
- [`selection_list()`](https://orijitghosh.github.io/rtui/reference/selection_list.md)
  : Create a selection list (multi-select)
- [`list_view()`](https://orijitghosh.github.io/rtui/reference/list_view.md)
  : Create a list view widget

## Charts

Terminal charts powered by plotext.

- [`text_plot()`](https://orijitghosh.github.io/rtui/reference/text_plot.md)
  : Create a text-based plot widget
- [`plot_bar()`](https://orijitghosh.github.io/rtui/reference/plot_bar.md)
  : Draw a bar chart on a plot widget
- [`plot_line()`](https://orijitghosh.github.io/rtui/reference/plot_line.md)
  : Draw a line plot on a plot widget
- [`plot_scatter()`](https://orijitghosh.github.io/rtui/reference/plot_scatter.md)
  : Draw a scatter plot on a plot widget
- [`plot_hist()`](https://orijitghosh.github.io/rtui/reference/plot_hist.md)
  : Draw a histogram on a plot widget
- [`plot_box()`](https://orijitghosh.github.io/rtui/reference/plot_box.md)
  : Draw a box plot on a plot widget
- [`plot_heatmap()`](https://orijitghosh.github.io/rtui/reference/plot_heatmap.md)
  : Draw a heatmap on a plot widget
- [`plot_candlestick()`](https://orijitghosh.github.io/rtui/reference/plot_candlestick.md)
  : Draw a candlestick chart on a plot widget
- [`plot_stacked_bar()`](https://orijitghosh.github.io/rtui/reference/plot_stacked_bar.md)
  : Draw a stacked bar chart on a plot widget
- [`plot_multiple_bar()`](https://orijitghosh.github.io/rtui/reference/plot_multiple_bar.md)
  : Draw a grouped (multiple) bar chart on a plot widget
- [`plot_error()`](https://orijitghosh.github.io/rtui/reference/plot_error.md)
  : Draw error bars on a plot widget
- [`plot_event()`](https://orijitghosh.github.io/rtui/reference/plot_event.md)
  : Draw an event plot on a plot widget
- [`plot_ggplot()`](https://orijitghosh.github.io/rtui/reference/plot_ggplot.md)
  : Render a ggplot2 object on a text_plot widget

## Widget updates

Modify widgets at runtime.

- [`update()`](https://orijitghosh.github.io/rtui/reference/update.md) :
  Update a widget by id
- [`notify()`](https://orijitghosh.github.io/rtui/reference/notify.md) :
  Show a notification
- [`log_write()`](https://orijitghosh.github.io/rtui/reference/log_write.md)
  : Write a line to a log_view widget
- [`dark_toggle()`](https://orijitghosh.github.io/rtui/reference/dark_toggle.md)
  : Toggle dark mode
- [`copy_to_clipboard()`](https://orijitghosh.github.io/rtui/reference/copy_to_clipboard.md)
  : Copy text to system clipboard

## Events

Event constructors (internal/testing).

- [`event_change()`](https://orijitghosh.github.io/rtui/reference/event_change.md)
  : Wrap a function as a change-event handler
- [`event_click()`](https://orijitghosh.github.io/rtui/reference/event_click.md)
  : Wrap a function as a click-event handler
- [`event_key()`](https://orijitghosh.github.io/rtui/reference/event_key.md)
  : Wrap a function as a key-event handler

## State and reactivity

Manage mutable app state.

- [`tui_state()`](https://orijitghosh.github.io/rtui/reference/tui_state.md)
  : Create a mutable TUI state object
- [`reactive()`](https://orijitghosh.github.io/rtui/reference/reactive.md)
  : Define reactive bindings between state keys and widgets

## Screens and dialogs

Multi-screen apps and modal dialogs.

- [`tui_screen()`](https://orijitghosh.github.io/rtui/reference/tui_screen.md)
  : Create a screen spec
- [`push_screen()`](https://orijitghosh.github.io/rtui/reference/push_screen.md)
  : Push a screen onto the screen stack
- [`pop_screen()`](https://orijitghosh.github.io/rtui/reference/pop_screen.md)
  : Pop the current screen from the stack
- [`confirm()`](https://orijitghosh.github.io/rtui/reference/confirm.md)
  : Show a confirmation dialog
- [`alert()`](https://orijitghosh.github.io/rtui/reference/alert.md) :
  Show an alert dialog

## Timers and workers

Scheduled and repeating tasks.

- [`set_timer()`](https://orijitghosh.github.io/rtui/reference/set_timer.md)
  : Create a one-shot timer
- [`set_interval()`](https://orijitghosh.github.io/rtui/reference/set_interval.md)
  : Create a repeating interval timer
- [`clear_timer()`](https://orijitghosh.github.io/rtui/reference/clear_timer.md)
  : Cancel a running timer
- [`set_worker()`](https://orijitghosh.github.io/rtui/reference/set_worker.md)
  : Start a background worker
- [`cancel_worker()`](https://orijitghosh.github.io/rtui/reference/cancel_worker.md)
  : Cancel a running worker

## Key bindings

Keyboard shortcuts and actions.

- [`binding()`](https://orijitghosh.github.io/rtui/reference/binding.md)
  : Create a key binding

## Command palette

Searchable command interface.

- [`command()`](https://orijitghosh.github.io/rtui/reference/command.md)
  : Define a command palette entry
- [`register_commands()`](https://orijitghosh.github.io/rtui/reference/register_commands.md)
  : Register commands for the command palette

## Forms

Structured form input.

- [`tui_form()`](https://orijitghosh.github.io/rtui/reference/tui_form.md)
  : Create a form with named inputs and a submit button
- [`collect_form()`](https://orijitghosh.github.io/rtui/reference/collect_form.md)
  : Collect form values from the running app

## Themes

Built-in colour themes.

- [`tui_theme()`](https://orijitghosh.github.io/rtui/reference/tui_theme.md)
  : Get a built-in theme CSS string
- [`list_themes()`](https://orijitghosh.github.io/rtui/reference/list_themes.md)
  : List available theme names

## Setup

Installation helpers.

- [`install_python_deps()`](https://orijitghosh.github.io/rtui/reference/install_python_deps.md)
  : Install Python dependencies for rtui
