# Package index

## App lifecycle

Create and run TUI applications.

- [`tui_app()`](tui_app.md) : Create a TUI application
- [`quick_app()`](quick_app.md) : Run a TUI app in one call
- [`quit()`](quit.md) : Signal app termination from a callback

## Convenience apps

One-call apps for common tasks.

- [`data_viewer()`](data_viewer.md) : Interactive data viewer
- [`browse_files()`](browse_files.md) : Interactive file browser

## Layout containers

Arrange widgets spatially.

- [`vstack()`](vstack.md) : Create a vertical stack layout
- [`hstack()`](hstack.md) : Create a horizontal stack layout
- [`grid()`](grid.md) : Create a grid layout
- [`center()`](center.md) : Create a center-aligned container
- [`middle()`](middle.md) : Create a middle-aligned container (vertical
  centering)
- [`scroll()`](scroll.md) : Create a scrollable container
- [`container()`](container.md) : Create a plain block container
- [`box()`](box.md) : Create a box widget with optional border

## Navigation widgets

Tabs, headers, footers, collapsibles, and trees.

- [`header()`](header.md) : Create a header widget
- [`footer()`](footer.md) : Create a footer widget
- [`tabs()`](tabs.md) : Create a tabbed pane container
- [`tab_pane()`](tab_pane.md) : Create a single tab pane
- [`collapsible()`](collapsible.md) : Create a collapsible section
- [`content_switcher()`](content_switcher.md) : Create a content
  switcher (shows one child at a time)
- [`tree()`](tree.md) : Create a tree widget
- [`directory_tree()`](directory_tree.md) : Create a directory tree
  widget

## Display widgets

Show text, data, and visual indicators.

- [`text()`](text.md) : Create a text widget
- [`static()`](static.md) : Create a static rich text widget
- [`markdown()`](markdown.md) : Create a markdown display widget
- [`digits()`](digits.md) : Create a large digits display widget
- [`pretty_table()`](pretty_table.md) : Create a pretty table widget
  (rich-formatted)
- [`sparkline()`](sparkline.md) : Create a sparkline widget
- [`progress_bar()`](progress_bar.md) : Create a progress bar widget
- [`rule()`](rule.md) : Create a horizontal rule (divider) widget
- [`loading()`](loading.md) : Create a loading indicator widget
- [`placeholder()`](placeholder.md) : Create a placeholder widget
- [`log_view()`](log_view.md) : Create an append-only log view widget

## Input widgets

Buttons, text fields, selects, and lists.

- [`button()`](button.md) : Create a button widget
- [`input()`](input.md) : Create a text input widget
- [`text_area()`](text_area.md) : Create a multi-line text area widget
- [`masked_input()`](masked_input.md) : Create a masked input widget
- [`checkbox()`](checkbox.md) : Create a checkbox widget
- [`switch_input()`](switch_input.md) : Create a switch (toggle) widget
- [`select()`](select.md) : Create a select dropdown widget
- [`radio_set()`](radio_set.md) : Create a radio set (group of radio
  buttons)
- [`radio_button()`](radio_button.md) : Create a radio button widget
  (use inside radio_set)
- [`data_table()`](data_table.md) : Create a data table widget
- [`option_list()`](option_list.md) : Create an option list widget
- [`selection_list()`](selection_list.md) : Create a selection list
  (multi-select)
- [`list_view()`](list_view.md) : Create a list view widget

## Charts

Terminal charts powered by plotext.

- [`text_plot()`](text_plot.md) : Create a text-based plot widget
- [`plot_bar()`](plot_bar.md) : Draw a bar chart on a plot widget
- [`plot_line()`](plot_line.md) : Draw a line plot on a plot widget
- [`plot_scatter()`](plot_scatter.md) : Draw a scatter plot on a plot
  widget
- [`plot_hist()`](plot_hist.md) : Draw a histogram on a plot widget
- [`plot_box()`](plot_box.md) : Draw a box plot on a plot widget
- [`plot_heatmap()`](plot_heatmap.md) : Draw a heatmap on a plot widget
- [`plot_candlestick()`](plot_candlestick.md) : Draw a candlestick chart
  on a plot widget
- [`plot_stacked_bar()`](plot_stacked_bar.md) : Draw a stacked bar chart
  on a plot widget
- [`plot_multiple_bar()`](plot_multiple_bar.md) : Draw a grouped
  (multiple) bar chart on a plot widget
- [`plot_error()`](plot_error.md) : Draw error bars on a plot widget
- [`plot_event()`](plot_event.md) : Draw an event plot on a plot widget
- [`plot_ggplot()`](plot_ggplot.md) : Render a ggplot2 object on a
  text_plot widget

## Widget updates

Modify widgets at runtime.

- [`update()`](update.md) : Update a widget by id
- [`notify()`](notify.md) : Show a notification
- [`log_write()`](log_write.md) : Write a line to a log_view widget
- [`dark_toggle()`](dark_toggle.md) : Toggle dark mode
- [`copy_to_clipboard()`](copy_to_clipboard.md) : Copy text to system
  clipboard

## Events

Event constructors (internal/testing).

- [`event_change()`](event_change.md) : Wrap a function as a
  change-event handler
- [`event_click()`](event_click.md) : Wrap a function as a click-event
  handler
- [`event_key()`](event_key.md) : Wrap a function as a key-event handler

## State and reactivity

Manage mutable app state.

- [`tui_state()`](tui_state.md) : Create a mutable TUI state object
- [`reactive()`](reactive.md) : Define reactive bindings between state
  keys and widgets

## Screens and dialogs

Multi-screen apps and modal dialogs.

- [`tui_screen()`](tui_screen.md) : Create a screen spec
- [`push_screen()`](push_screen.md) : Push a screen onto the screen
  stack
- [`pop_screen()`](pop_screen.md) : Pop the current screen from the
  stack
- [`confirm()`](confirm.md) : Show a confirmation dialog
- [`alert()`](alert.md) : Show an alert dialog

## Timers and workers

Scheduled and repeating tasks.

- [`set_timer()`](set_timer.md) : Create a one-shot timer
- [`set_interval()`](set_interval.md) : Create a repeating interval
  timer
- [`clear_timer()`](clear_timer.md) : Cancel a running timer
- [`set_worker()`](set_worker.md) : Start a background worker
- [`cancel_worker()`](cancel_worker.md) : Cancel a running worker

## Key bindings

Keyboard shortcuts and actions.

- [`binding()`](binding.md) : Create a key binding

## Command palette

Searchable command interface.

- [`command()`](command.md) : Define a command palette entry
- [`register_commands()`](register_commands.md) : Register commands for
  the command palette

## Forms

Structured form input.

- [`tui_form()`](tui_form.md) : Create a form with named inputs and a
  submit button
- [`collect_form()`](collect_form.md) : Collect form values from the
  running app

## Themes

Built-in colour themes.

- [`tui_theme()`](tui_theme.md) : Get a built-in theme CSS string
- [`list_themes()`](list_themes.md) : List available theme names

## Setup

Installation helpers.

- [`install_python_deps()`](install_python_deps.md) : Install Python
  dependencies for rtui
