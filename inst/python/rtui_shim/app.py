"""RtuiApp: Textual App subclass driven by R callbacks."""

from __future__ import annotations

from typing import Any, Callable, Optional

from textual.app import App, ComposeResult
from textual.screen import Screen
from textual.widgets import (
    DataTable,
    Digits,
    DirectoryTree,
    ListView,
    Checkbox,
    RadioButton,
    RadioSet,
    RichLog,
    Select,
    Sparkline,
    Switch,
    TextArea,
    OptionList,
    SelectionList,
    ProgressBar,
    TabbedContent,
    Tree,
)

from .factory import build_widget, RtuiSpecError
from .bridge import make_event_dict


class RtuiApp(App):

    def __init__(
        self,
        spec: dict,
        callback_dispatcher: Callable,
        css_text: Optional[str] = None,
        title: Optional[str] = None,
        sub_title: Optional[str] = None,
        dark: bool = True,
        bindings: Optional[list] = None,
        **kwargs,
    ):
        # Set up bindings BEFORE super().__init__() so Textual sees them
        # when it caches the binding map during App initialization.
        if bindings:
            self._setup_bindings(bindings)
        if css_text:
            self.__class__.CSS = css_text
        super().__init__(**kwargs)
        self._spec = spec
        self._callback_dispatcher = callback_dispatcher
        self._exit_pending = False
        self._exit_result: Any = None
        self._rtui_timers: dict = {}
        self._rtui_commands: list = []
        if title is not None:
            self.title = title
        if sub_title is not None:
            self.sub_title = sub_title
        self.dark = dark

    def compose(self) -> ComposeResult:
        root = build_widget(self._spec)
        yield root

    def on_mount(self) -> None:
        for dt in self.query(DataTable):
            if hasattr(dt, "_rtui_df"):
                self._populate_data_table(dt, dt._rtui_df)

        for pb in self.query(ProgressBar):
            if hasattr(pb, "_rtui_initial_progress"):
                pb.advance(pb._rtui_initial_progress)

        for sel in self.query(Select):
            if hasattr(sel, "_rtui_initial_value"):
                sel.value = sel._rtui_initial_value

        event = make_event_dict("mount")
        self._dispatch(event)

    # --- Key events ---
    def on_key(self, event) -> None:
        ev = make_event_dict("key", key=event.key)
        self._dispatch(ev)

    # --- Input events ---
    def on_input_changed(self, event) -> None:
        widget_id = event.input.id if event.input else None
        val = event.value
        # Include validation result if validators are set
        if event.validation_result is not None:
            val = {
                "text": event.value,
                "valid": event.validation_result.is_valid,
                "failures": [
                    str(f) for f in (event.validation_result.failure_descriptions or [])
                ],
            }
        ev = make_event_dict("change", widget_id=widget_id, value=val)
        self._dispatch(ev)

    def on_input_submitted(self, event) -> None:
        widget_id = event.input.id if event.input else None
        val = event.value
        if event.validation_result is not None:
            val = {
                "text": event.value,
                "valid": event.validation_result.is_valid,
                "failures": [
                    str(f) for f in (event.validation_result.failure_descriptions or [])
                ],
            }
        ev = make_event_dict("submit", widget_id=widget_id, value=val)
        self._dispatch(ev)

    def on_text_area_changed(self, event: TextArea.Changed) -> None:
        widget_id = event.text_area.id if event.text_area else None
        ev = make_event_dict("change", widget_id=widget_id, value=event.text_area.text)
        self._dispatch(ev)

    # --- ListView events ---
    def on_list_view_highlighted(self, event: ListView.Highlighted) -> None:
        widget_id = event.list_view.id if event.list_view else None
        item_index = event.list_view.index if event.list_view else None
        label = ""
        if event.item is not None:
            label_widget = event.item.query("Label")
            if label_widget:
                label = str(label_widget.first().renderable)
        ev = make_event_dict(
            "change", widget_id=widget_id,
            value={"index": item_index, "label": label},
        )
        self._dispatch(ev)

    def on_list_view_selected(self, event: ListView.Selected) -> None:
        widget_id = event.list_view.id if event.list_view else None
        item_index = event.list_view.index if event.list_view else None
        label = ""
        if event.item is not None:
            label_widget = event.item.query("Label")
            if label_widget:
                label = str(label_widget.first().renderable)
        ev = make_event_dict(
            "click", widget_id=widget_id,
            value={"index": item_index, "label": label},
        )
        self._dispatch(ev)

    # --- Button events ---
    def on_button_pressed(self, event) -> None:
        widget_id = event.button.id if event.button else None
        # Handle built-in dialog buttons automatically
        if widget_id == "__dlg_yes":
            self.pop_screen()
            self._on_screen_dismissed(True)
            return
        if widget_id == "__dlg_no":
            self.pop_screen()
            self._on_screen_dismissed(False)
            return
        ev = make_event_dict("click", widget_id=widget_id)
        self._dispatch(ev)

    # --- Checkbox / Switch / Radio events ---
    def on_checkbox_changed(self, event: Checkbox.Changed) -> None:
        widget_id = event.checkbox.id if event.checkbox else None
        ev = make_event_dict("change", widget_id=widget_id, value=event.value)
        self._dispatch(ev)

    def on_switch_changed(self, event: Switch.Changed) -> None:
        widget_id = event.switch.id if event.switch else None
        ev = make_event_dict("change", widget_id=widget_id, value=event.value)
        self._dispatch(ev)

    def on_radio_set_changed(self, event: RadioSet.Changed) -> None:
        widget_id = event.radio_set.id if event.radio_set else None
        ev = make_event_dict(
            "change", widget_id=widget_id,
            value={"index": event.index, "label": str(event.pressed.label)},
        )
        self._dispatch(ev)

    # --- Select events ---
    def on_select_changed(self, event: Select.Changed) -> None:
        widget_id = event.select.id if event.select else None
        val = event.value
        # Select.BLANK is a sentinel when nothing is selected
        if val is Select.BLANK:
            val = None
        ev = make_event_dict("change", widget_id=widget_id, value=val)
        self._dispatch(ev)

    # --- OptionList events ---
    def on_option_list_option_highlighted(self, event: OptionList.OptionHighlighted) -> None:
        widget_id = event.option_list.id if event.option_list else None
        ev = make_event_dict(
            "change", widget_id=widget_id,
            value={"index": event.option_index, "label": str(event.option.prompt)},
        )
        self._dispatch(ev)

    def on_option_list_option_selected(self, event: OptionList.OptionSelected) -> None:
        widget_id = event.option_list.id if event.option_list else None
        ev = make_event_dict(
            "click", widget_id=widget_id,
            value={"index": event.option_index, "label": str(event.option.prompt)},
        )
        self._dispatch(ev)

    # --- SelectionList events ---
    def on_selection_list_selected_changed(self, event: SelectionList.SelectedChanged) -> None:
        widget_id = event.selection_list.id if event.selection_list else None
        selected = [str(s) for s in event.selection_list.selected]
        ev = make_event_dict("change", widget_id=widget_id, value=selected)
        self._dispatch(ev)

    # --- Tab events ---
    def on_tabbed_content_tab_activated(self, event: TabbedContent.TabActivated) -> None:
        widget_id = event.tabbed_content.id if event.tabbed_content else None
        tab_id = event.tab.id if event.tab else None
        ev = make_event_dict(
            "change", widget_id=widget_id,
            value={"tab_id": tab_id},
        )
        self._dispatch(ev)

    # --- Tree events ---
    def on_tree_node_highlighted(self, event: Tree.NodeHighlighted) -> None:
        tree = event.node.tree
        widget_id = tree.id if tree else None
        ev = make_event_dict(
            "change", widget_id=widget_id,
            value={"label": str(event.node.label), "is_leaf": not event.node.children},
        )
        self._dispatch(ev)

    def on_tree_node_selected(self, event: Tree.NodeSelected) -> None:
        tree = event.node.tree
        widget_id = tree.id if tree else None
        ev = make_event_dict(
            "click", widget_id=widget_id,
            value={"label": str(event.node.label), "is_leaf": not event.node.children},
        )
        self._dispatch(ev)

    # --- DirectoryTree events ---
    def on_directory_tree_file_selected(self, event: DirectoryTree.FileSelected) -> None:
        tree = event.node.tree
        widget_id = tree.id if tree else None
        ev = make_event_dict(
            "click", widget_id=widget_id,
            value={"path": str(event.path), "is_file": True},
        )
        self._dispatch(ev)

    def on_directory_tree_directory_selected(self, event: DirectoryTree.DirectorySelected) -> None:
        tree = event.node.tree
        widget_id = tree.id if tree else None
        ev = make_event_dict(
            "click", widget_id=widget_id,
            value={"path": str(event.path), "is_file": False},
        )
        self._dispatch(ev)

    # --- DataTable events ---
    def _get_row_data(self, dt: DataTable, row_key) -> dict:
        """Extract a dict of column→value for a given row key."""
        try:
            row_vals = dt.get_row(row_key)
            col_keys = list(dt.columns.keys())
            col_labels = [str(dt.columns[k].label) for k in col_keys]
            return dict(zip(col_labels, [str(v) for v in row_vals]))
        except Exception:
            return {}

    def on_data_table_row_selected(self, event: DataTable.RowSelected) -> None:
        widget_id = event.data_table.id if event.data_table else None
        row_key_str = str(event.row_key.value) if event.row_key else None
        row_data = self._get_row_data(event.data_table, event.row_key) if event.row_key else {}
        ev = make_event_dict(
            "click", widget_id=widget_id,
            value={"row_key": row_key_str, "row_data": row_data},
        )
        self._dispatch(ev)

    def on_data_table_row_highlighted(self, event: DataTable.RowHighlighted) -> None:
        widget_id = event.data_table.id if event.data_table else None
        row_key_str = str(event.row_key.value) if event.row_key else None
        ev = make_event_dict(
            "change", widget_id=widget_id,
            value={"row_key": row_key_str},
        )
        self._dispatch(ev)

    @staticmethod
    def _mixed_sort_key(values):
        """Sort key that handles mixed str/numeric types from R data frames.
        Numbers sort numerically before strings.
        Textual passes a scalar for single-column sort, tuple for multi-column."""
        if not isinstance(values, tuple):
            values = (values,)
        result = []
        for v in values:
            try:
                result.append((0, float(v)))
            except (ValueError, TypeError):
                result.append((1, str(v)))
        return tuple(result)

    def on_data_table_header_selected(self, event: DataTable.HeaderSelected) -> None:
        """Sort column when header is clicked (if sortable)."""
        dt = event.data_table
        if not getattr(dt, "_rtui_sortable", False):
            return
        col_key = event.column_key
        sort_state = getattr(dt, "_rtui_sort_state", {})
        # Toggle: None -> ascending -> descending -> ascending ...
        current = sort_state.get(str(col_key), None)
        reverse = current == "asc"  # if was ascending, flip to descending
        dt.sort(col_key, key=self._mixed_sort_key, reverse=reverse)
        sort_state[str(col_key)] = "desc" if reverse else "asc"
        dt._rtui_sort_state = sort_state
        widget_id = dt.id if dt else None
        ev = make_event_dict(
            "change", widget_id=widget_id,
            value={"sort_column": str(event.label), "reverse": reverse},
        )
        self._dispatch(ev)

    def on_data_table_cell_selected(self, event: DataTable.CellSelected) -> None:
        widget_id = event.data_table.id if event.data_table else None
        ev = make_event_dict(
            "click", widget_id=widget_id,
            value={
                "row_key": str(event.cell_key.row_key.value) if event.cell_key else None,
                "column_key": str(event.cell_key.column_key.value) if event.cell_key else None,
                "cell_value": str(event.value) if event.value is not None else None,
            },
        )
        self._dispatch(ev)

    # --- Resize ---
    def on_resize(self, event) -> None:
        ev = make_event_dict(
            "resize", width=event.size.width, height=event.size.height
        )
        self._dispatch(ev)

    # --- Dispatch and control ---
    def _dispatch(self, event_dict: dict) -> None:
        if self._exit_pending:
            return
        try:
            self._callback_dispatcher(event_dict)
        except SystemExit:
            raise
        except Exception as exc:
            self.log.error(f"R callback error: {exc}")
            # Surface the error as a notification so it's visible
            try:
                self.notify(
                    f"Callback error: {exc}",
                    severity="error",
                    timeout=10,
                )
            except Exception:
                pass

    # --- Bindings support ---
    def _setup_bindings(self, bindings: list) -> None:
        from textual.binding import Binding

        binding_list = []
        for b in bindings:
            key = b.get("key", "")
            action = b.get("action", "")
            desc = b.get("description", "")
            priority = bool(b.get("priority", False))
            binding_list.append(Binding(key, f"rtui_{action}", desc, priority=priority))
            # Register a dynamic action method for this action
            method_name = f"action_rtui_{action}"
            if not hasattr(self, method_name):
                action_name = action  # capture for closure

                def make_handler(name):
                    def handler(self_inner):
                        ev = make_event_dict("action", value=name)
                        self_inner._dispatch(ev)
                    return handler

                bound_method = make_handler(action_name)
                setattr(self.__class__, method_name, bound_method)
        self.__class__.BINDINGS = binding_list

    # --- Screen support ---
    def _make_screen(self, spec_dict: dict) -> Screen:
        """Dynamically create a Screen from a spec dict."""
        layout_spec = spec_dict.get("layout", spec_dict)
        css_text = spec_dict.get("css")

        class DynamicScreen(Screen):
            SCOPED_CSS = False

            def compose(inner_self) -> ComposeResult:
                yield build_widget(layout_spec)

        if css_text:
            DynamicScreen.CSS = css_text
        return DynamicScreen()

    def push_screen_from_spec(self, spec_dict: dict) -> None:
        screen = self._make_screen(spec_dict)
        self.push_screen(screen, callback=self._on_screen_dismissed)

    def _on_screen_dismissed(self, result: Any = None) -> None:
        if self._exit_pending:
            return
        ev = make_event_dict("screen_result", value=result)
        self._dispatch(ev)

    def pop_screen_with_result(self, result: Any = None) -> None:
        self.pop_screen()
        if result is not None:
            self._on_screen_dismissed(result)

    # --- Timer support ---
    def create_timer(self, name: str, interval: float, is_repeat: bool) -> None:
        self.cancel_timer(name)
        if is_repeat:
            timer = self.set_interval(
                interval, lambda: self._fire_timer(name), name=name
            )
        else:
            timer = self.set_timer(
                interval, lambda: self._fire_timer(name), name=name
            )
        self._rtui_timers[name] = timer

    def _fire_timer(self, name: str) -> None:
        """Schedule R dispatch via call_later so it runs in Textual's message loop,
        not directly from the asyncio timer task."""
        if self._exit_pending:
            return
        timer_name = name  # capture for closure

        def _do_dispatch():
            if self._exit_pending:
                return
            ev = make_event_dict("timer", timer_id=timer_name)
            self._dispatch(ev)

        self.call_later(_do_dispatch)

    def cancel_timer(self, name: str) -> None:
        timer = self._rtui_timers.pop(name, None)
        if timer is not None:
            timer.stop()

    def request_exit(self, result: Any = None) -> None:
        self._exit_pending = True
        self._exit_result = result
        self.exit(result)

    def set_dark(self, dark: bool) -> None:
        """Toggle dark mode at runtime."""
        self.dark = dark

    def copy_to_clipboard(self, text: str) -> None:
        """Copy text to the system clipboard via Textual."""
        self.copy_to_clipboard_native(text)

    def copy_to_clipboard_native(self, text: str) -> None:
        """Copy text using platform clipboard tools."""
        import subprocess
        import sys
        try:
            if sys.platform == "win32":
                subprocess.run(
                    ["clip"], input=text.encode("utf-16le"),
                    check=True, timeout=5,
                )
            elif sys.platform == "darwin":
                subprocess.run(
                    ["pbcopy"], input=text.encode(),
                    check=True, timeout=5,
                )
            else:
                subprocess.run(
                    ["xclip", "-selection", "clipboard"],
                    input=text.encode(), check=True, timeout=5,
                )
        except Exception:
            pass  # Silently fail if clipboard tool not available

    # --- Command palette support ---
    def register_commands(self, commands: list) -> None:
        """Register commands for the command palette.
        Each command is a dict with 'name' and 'action' keys.
        """
        self._rtui_commands = list(commands)

    def get_system_commands(self, screen):
        """Override to add custom R commands to the palette."""
        # Get built-in commands first
        for cmd in super().get_system_commands(screen):
            yield cmd
        # Add R-registered commands
        for cmd_spec in self._rtui_commands:
            name = cmd_spec.get("name", "")
            action = cmd_spec.get("action", "")
            help_text = cmd_spec.get("help", "")

            from textual.command import SystemCommand

            def make_callback(act):
                def callback():
                    ev = make_event_dict("action", value=act)
                    self._dispatch(ev)
                return callback

            yield SystemCommand(name, help_text, make_callback(action))

    def apply_update(self, widget_id: str, patch: dict) -> None:
        try:
            widget = self.query_one(f"#{widget_id}")
        except Exception:
            raise RtuiSpecError(f"Widget not found: {widget_id!r}")

        for key, value in patch.items():
            if key == "content":
                if hasattr(widget, "update"):
                    widget.update(value)
                elif hasattr(widget, "renderable"):
                    widget.renderable = value
                else:
                    raise RtuiSpecError(
                        f"Widget {widget_id!r} does not support 'content' updates"
                    )
            elif key == "value" and isinstance(widget, Digits):
                # Digits must use .update() to re-render
                widget.update(str(value))
            elif key == "value" and isinstance(widget, TextArea):
                # TextArea uses .text, not .value
                widget.text = str(value)
            elif key == "value" and hasattr(widget, "value"):
                widget.value = value
            elif key == "label" and hasattr(widget, "label"):
                widget.label = value
            elif key == "items" and isinstance(widget, OptionList):
                widget.clear_options()
                for item in value:
                    widget.add_option(str(item))
            elif key == "items" and hasattr(widget, "clear"):
                widget.clear()
                from textual.widgets import Label, ListItem
                for item in value:
                    widget.append(ListItem(Label(str(item))))
            elif key == "data" and hasattr(widget, "data"):
                widget.data = value
            elif key == "progress" and isinstance(widget, ProgressBar):
                widget.update(progress=value)
            elif key == "total" and isinstance(widget, ProgressBar):
                widget.update(total=value)
            elif key == "collapsed" and hasattr(widget, "collapsed"):
                widget.collapsed = value
            elif key == "disabled" and hasattr(widget, "disabled"):
                widget.disabled = value
            elif key == "display" and hasattr(widget, "display"):
                widget.display = value
            elif key == "visible" and hasattr(widget, "visible"):
                widget.visible = value
            elif key == "add_rows" and isinstance(widget, DataTable):
                row_data = value
                # Handle pandas DataFrames
                try:
                    import pandas as pd
                    if isinstance(row_data, pd.DataFrame):
                        if row_data.empty:
                            continue
                        row_data = {col: row_data[col].tolist() for col in row_data.columns}
                except ImportError:
                    pass
                if isinstance(row_data, dict) and row_data:
                    cols = list(row_data.keys())
                    # Add columns if table is empty
                    if not widget.columns:
                        for col in cols:
                            widget.add_column(col, key=col)
                    n_rows = len(row_data[cols[0]])
                    for i in range(n_rows):
                        row = [row_data[col][i] for col in cols]
                        widget.add_row(*row)
            elif key == "remove_rows" and isinstance(widget, DataTable):
                for row_key in value:
                    try:
                        widget.remove_row(row_key)
                    except Exception:
                        pass
            elif key == "clear_data" and isinstance(widget, DataTable):
                widget.clear()
                # Also remove all columns so new data can define its own
                for col_key in list(widget.columns.keys()):
                    try:
                        widget.remove_column(col_key)
                    except Exception:
                        pass
            elif key == "sort_column" and isinstance(widget, DataTable):
                col_key = value if isinstance(value, str) else value.get("column")
                reverse = False if isinstance(value, str) else value.get("reverse", False)
                widget.sort(col_key, reverse=reverse)
            elif key == "write" and isinstance(widget, RichLog):
                # Append text to a RichLog widget
                if isinstance(value, dict):
                    text = value.get("text", "")
                    markup = value.get("markup", False)
                    if markup and hasattr(widget, "write_markup"):
                        widget.write_markup(text)
                    else:
                        widget.write(text)
                else:
                    widget.write(str(value))
            elif key == "clear" and isinstance(widget, RichLog):
                widget.clear()
            elif key == "data" and isinstance(widget, Sparkline):
                widget.data = list(value)
            elif key == "add_class":
                if isinstance(value, str):
                    widget.add_class(value)
                elif isinstance(value, (list, tuple)):
                    for cls in value:
                        widget.add_class(str(cls))
            elif key == "remove_class":
                if isinstance(value, str):
                    widget.remove_class(value)
                elif isinstance(value, (list, tuple)):
                    for cls in value:
                        widget.remove_class(str(cls))
            elif key == "scroll_visible":
                widget.scroll_visible()
            elif key == "focus":
                if value:
                    widget.focus()
            elif key == "styles":
                # Apply inline CSS styles
                if isinstance(value, dict):
                    for style_key, style_val in value.items():
                        try:
                            setattr(widget.styles, style_key.replace("-", "_"), style_val)
                        except Exception:
                            pass
            else:
                raise RtuiSpecError(
                    f"Unknown property {key!r} for widget {widget_id!r}"
                )

    def get_widget_value(self, widget_id: str):
        """Return the current value of a widget by id (for form collection)."""
        try:
            widget = self.query_one(f"#{widget_id}")
        except Exception:
            return None
        if isinstance(widget, DataTable):
            return None  # DataTable doesn't have a scalar value
        if isinstance(widget, Checkbox):
            return widget.value
        if isinstance(widget, Switch):
            return widget.value
        if isinstance(widget, RadioSet):
            idx = widget.pressed_index
            return idx if idx is not None else -1
        if isinstance(widget, Select):
            return widget.value if widget.value != Select.BLANK else None
        if isinstance(widget, TextArea):
            return widget.text
        if hasattr(widget, "value"):
            return widget.value
        return None

    def send_notify(self, message: str, severity: str = "info") -> None:
        severity_map = {
            "info": "information",
            "warning": "warning",
            "error": "error",
        }
        super().notify(
            message, severity=severity_map.get(severity, "information")
        )

    def draw_plot(self, widget_id: str, spec: dict) -> None:
        """Draw a plot on a PlotextPlot widget."""
        try:
            from textual_plotext import PlotextPlot
        except ImportError:
            raise RtuiSpecError("textual-plotext is not installed.")

        try:
            widget = self.query_one(f"#{widget_id}")
        except Exception:
            raise RtuiSpecError(f"Widget not found: {widget_id!r}")

        if not isinstance(widget, PlotextPlot):
            raise RtuiSpecError(f"Widget {widget_id!r} is not a text_plot.")

        plt = widget.plt
        plot_type = spec.get("type", "bar")
        clear = spec.get("clear", True)

        if clear:
            plt.clear_data()
            plt.clear_figure()

        title = spec.get("title")
        if title:
            plt.title(title)

        xlabel = spec.get("xlabel")
        if xlabel:
            plt.xlabel(xlabel)

        ylabel = spec.get("ylabel")
        if ylabel:
            plt.ylabel(ylabel)

        color = spec.get("color")

        if plot_type == "bar":
            labels = list(spec.get("labels", []))
            values = list(spec.get("values", []))
            orientation = spec.get("orientation", "vertical")
            kwargs = {}
            if color:
                kwargs["color"] = color
            if orientation == "horizontal":
                kwargs["orientation"] = "horizontal"
            plt.bar(labels, values, **kwargs)

        elif plot_type == "line":
            x = list(spec.get("x", []))
            y = list(spec.get("y", []))
            kwargs = {}
            if color:
                kwargs["color"] = color
            marker = spec.get("marker")
            if marker:
                kwargs["marker"] = marker
            plt.plot(x, y, **kwargs)

        elif plot_type == "scatter":
            x = list(spec.get("x", []))
            y = list(spec.get("y", []))
            kwargs = {}
            if color:
                kwargs["color"] = color
            marker = spec.get("marker")
            if marker:
                kwargs["marker"] = marker
            plt.scatter(x, y, **kwargs)

        elif plot_type == "hist":
            data = list(spec.get("data", []))
            bins = int(spec.get("bins", 10))
            kwargs = {}
            if color:
                kwargs["color"] = color
            plt.hist(data, bins, **kwargs)

        elif plot_type == "box":
            data = spec.get("data", [])
            # data may arrive as dict (named list from R) or list
            if isinstance(data, dict):
                labels = spec.get("labels") or list(data.keys())
                groups = [list(v) for v in data.values()]
            else:
                groups = [list(g) for g in data]
                labels = spec.get("labels")
            kwargs = {}
            colors = spec.get("colors")
            if colors:
                kwargs["colors"] = list(colors)
            orientation = spec.get("orientation", "vertical")
            if orientation == "horizontal":
                kwargs["orientation"] = "horizontal"
            if labels:
                plt.box(list(labels), groups, **kwargs)
            else:
                plt.box(groups, **kwargs)

        elif plot_type == "stacked_bar":
            labels = list(spec.get("labels", []))
            series = spec.get("series", [])
            # series may arrive as dict (named list from R) or list
            if isinstance(series, dict):
                series_labels = spec.get("series_labels") or list(series.keys())
                y_matrix = [list(v) for v in series.values()]
            else:
                y_matrix = [list(s) for s in series]
                series_labels = spec.get("series_labels")
            kwargs = {}
            colors = spec.get("colors")
            if colors:
                kwargs["color"] = list(colors)
            if series_labels:
                kwargs["labels"] = list(series_labels)
            orientation = spec.get("orientation", "vertical")
            if orientation == "horizontal":
                kwargs["orientation"] = "horizontal"
            plt.stacked_bar(labels, y_matrix, **kwargs)

        elif plot_type == "multiple_bar":
            labels = list(spec.get("labels", []))
            series = spec.get("series", [])
            # series may arrive as dict (named list from R) or list
            if isinstance(series, dict):
                series_labels = spec.get("series_labels") or list(series.keys())
                y_matrix = [list(v) for v in series.values()]
            else:
                y_matrix = [list(s) for s in series]
                series_labels = spec.get("series_labels")
            kwargs = {}
            colors = spec.get("colors")
            if colors:
                kwargs["color"] = list(colors)
            if series_labels:
                kwargs["labels"] = list(series_labels)
            orientation = spec.get("orientation", "vertical")
            if orientation == "horizontal":
                kwargs["orientation"] = "horizontal"
            plt.multiple_bar(labels, y_matrix, **kwargs)

        elif plot_type == "heatmap":
            matrix = spec.get("matrix", [])
            # matrix may arrive as dict (named list) or list-of-lists
            if isinstance(matrix, dict):
                mat = [list(v) for v in matrix.values()]
            else:
                mat = [list(row) for row in matrix]
            # heatmap() requires a pandas DataFrame
            import pandas as pd
            df = pd.DataFrame(mat)
            kwargs = {}
            if color:
                kwargs["color"] = color
            plt.heatmap(df, **kwargs)

        elif plot_type == "candlestick":
            dates = list(spec.get("dates", []))
            open_vals = list(spec.get("open", []))
            close_vals = list(spec.get("close", []))
            high_vals = list(spec.get("high", []))
            low_vals = list(spec.get("low", []))
            # plotext candlestick expects: dates, data where data is
            # [[open, close, high, low], ...] for each date
            candle_data = list(zip(open_vals, close_vals, high_vals, low_vals))
            kwargs = {}
            colors = spec.get("colors")
            if colors:
                kwargs["colors"] = list(colors)
            plt.candlestick(dates, candle_data, **kwargs)

        elif plot_type == "error":
            x = list(spec.get("x", []))
            y = list(spec.get("y", []))
            kwargs = {}
            if color:
                kwargs["color"] = color
            xerr = spec.get("xerr")
            if xerr is not None:
                kwargs["xerr"] = list(xerr)
            yerr = spec.get("yerr")
            if yerr is not None:
                kwargs["yerr"] = list(yerr)
            plt.error(x, y, **kwargs)

        elif plot_type == "event":
            positions = list(spec.get("positions", []))
            kwargs = {}
            if color:
                kwargs["color"] = color
            orientation = spec.get("orientation", "vertical")
            if orientation == "horizontal":
                kwargs["orientation"] = "horizontal"
            plt.event_plot(positions, **kwargs)

        else:
            raise RtuiSpecError(f"Unknown plot type: {plot_type!r}")

        widget.refresh()

    @staticmethod
    def _populate_data_table(dt: DataTable, df: Any) -> None:
        if df is None:
            return
        # Handle pandas DataFrames (reticulate may convert R data.frames)
        try:
            import pandas as pd
            if isinstance(df, pd.DataFrame):
                if df.empty:
                    return
                df = {col: df[col].tolist() for col in df.columns}
        except ImportError:
            pass
        if not isinstance(df, dict) or not df:
            return
        cols = list(df.keys())
        for col in cols:
            dt.add_column(col, key=col)
        if cols:
            n_rows = len(df[cols[0]])
            for i in range(n_rows):
                row = [df[col][i] for col in cols]
                dt.add_row(*row)
