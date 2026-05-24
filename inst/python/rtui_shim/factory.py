"""Widget factory: converts R spec dicts to Textual widgets."""

from __future__ import annotations

from textual.widgets import (
    Static,
    Input,
    Button,
    ListView,
    ListItem,
    DataTable,
    Label,
    RichLog,
    Checkbox,
    RadioButton,
    RadioSet,
    Select,
    Switch,
    TextArea,
    OptionList,
    SelectionList,
    Markdown,
    ProgressBar,
    Sparkline,
    Rule,
    LoadingIndicator,
    Digits,
    Placeholder,
    Header,
    Footer,
    Collapsible,
    ContentSwitcher,
    TabbedContent,
    TabPane,
    Tree,
    DirectoryTree,
    MaskedInput,
    Pretty,
)
from textual.containers import (
    Vertical,
    Horizontal,
    Grid,
    Container,
    ScrollableContainer,
    Center,
    Middle,
)


class RtuiSpecError(Exception):
    pass


_CONTAINER_MAP = {
    "vstack": Vertical,
    "hstack": Horizontal,
    "grid": Grid,
    "container": Container,
    "scroll": ScrollableContainer,
    "center": Center,
    "middle": Middle,
}


def build_widget(spec: dict):
    """Build a Textual widget from a spec dict. Applies tooltip if set."""
    widget = _build_widget_inner(spec)
    props_raw = spec.get("props") or {}
    tooltip = props_raw.get("tooltip") if isinstance(props_raw, dict) else None
    if tooltip:
        widget.tooltip = tooltip
    return widget


def _build_widget_inner(spec: dict):
    kind = spec.get("kind")
    widget_id = spec.get("id")
    classes = " ".join(spec.get("classes") or []) or None
    props = spec.get("props") or {}
    if not isinstance(props, dict):
        props = {}
    children_specs = spec.get("children") or []

    # --- Containers ---
    if kind in _CONTAINER_MAP:
        children = [build_widget(c) for c in children_specs]
        container_cls = _CONTAINER_MAP[kind]
        return container_cls(*children, id=widget_id, classes=classes)

    if kind == "box":
        children = [build_widget(c) for c in children_specs]
        border = props.get("border", "none")
        title = props.get("title")
        widget = Container(*children, id=widget_id, classes=classes)
        if border != "none":
            border_map = {"round": "round", "heavy": "heavy", "double": "double"}
            widget.styles.border = (border_map.get(border, "round"), "green")
        if title:
            widget.border_title = title
        return widget

    # --- Display widgets ---
    if kind == "text":
        return Label(props.get("content", ""), id=widget_id, classes=classes)

    if kind == "static":
        return Static(props.get("content", ""), id=widget_id, classes=classes)

    if kind == "log_view":
        max_lines = props.get("max_lines", 1000)
        return RichLog(id=widget_id, classes=classes, max_lines=max_lines)

    if kind == "markdown":
        return Markdown(props.get("content", ""), id=widget_id, classes=classes)

    if kind == "progress_bar":
        widget = ProgressBar(
            total=props.get("total", 100),
            show_eta=props.get("show_eta", True),
            show_percentage=props.get("show_percentage", True),
            id=widget_id,
            classes=classes,
        )
        progress = props.get("progress", 0)
        if progress > 0:
            widget._rtui_initial_progress = progress
        return widget

    if kind == "sparkline":
        data = props.get("data", [])
        return Sparkline(data, id=widget_id, classes=classes)

    if kind == "rule":
        label = props.get("label")
        if label:
            return Static(f"── {label} ──", id=widget_id, classes=classes)
        return Rule(id=widget_id, classes=classes)

    if kind == "loading":
        return LoadingIndicator(id=widget_id, classes=classes)

    if kind == "digits":
        return Digits(props.get("value", ""), id=widget_id, classes=classes)

    if kind == "placeholder":
        return Placeholder(props.get("label", "Placeholder"), id=widget_id, classes=classes)

    if kind == "pretty_table":
        df = props.get("df", {})
        title = props.get("title")
        from rich.table import Table as RichTable

        table = RichTable(title=title)
        if isinstance(df, dict) and df:
            cols = list(df.keys())
            for col in cols:
                table.add_column(col)
            if cols:
                n_rows = len(df[cols[0]])
                for i in range(n_rows):
                    table.add_row(*[str(df[col][i]) for col in cols])
        return Static(table, id=widget_id, classes=classes)

    # --- Input widgets ---
    if kind == "input":
        validators_spec = props.get("validators")
        validators = _parse_validators(validators_spec) if validators_spec else None
        return Input(
            placeholder=props.get("placeholder", ""),
            value=props.get("value", ""),
            validators=validators,
            id=widget_id,
            classes=classes,
        )

    if kind == "button":
        return Button(props.get("label", ""), id=widget_id, classes=classes)

    if kind == "list_view":
        items = props.get("items", [])
        list_items = [ListItem(Label(str(item))) for item in items]
        return ListView(*list_items, id=widget_id, classes=classes)

    if kind == "data_table":
        df = props.get("df", {})
        cursor = props.get("cursor", "row")
        zebra = props.get("zebra_stripes", False)
        sortable = props.get("sortable", False)
        table = DataTable(
            id=widget_id, classes=classes,
            cursor_type=cursor, zebra_stripes=zebra,
        )
        table._rtui_df = df
        table._rtui_sortable = sortable
        # Track sort state per column for toggle behaviour
        table._rtui_sort_state = {}
        return table

    if kind == "checkbox":
        return Checkbox(
            props.get("label", ""),
            props.get("value", False),
            id=widget_id,
            classes=classes,
        )

    if kind == "radio_button":
        return RadioButton(
            props.get("label", ""),
            props.get("value", False),
            id=widget_id,
            classes=classes,
        )

    if kind == "radio_set":
        children = [build_widget(c) for c in children_specs]
        return RadioSet(*children, id=widget_id, classes=classes)

    if kind == "select":
        options = props.get("options", [])
        prompt = props.get("prompt", "Select...")
        value = props.get("value")
        if isinstance(options, dict):
            select_options = [(v, k) for k, v in options.items()]
        else:
            select_options = [(o, o) for o in options]
        widget = Select(
            select_options,
            prompt=prompt,
            id=widget_id,
            classes=classes,
        )
        if value is not None:
            widget._rtui_initial_value = value
        return widget

    if kind == "switch":
        return Switch(
            value=props.get("value", False),
            id=widget_id,
            classes=classes,
        )

    if kind == "text_area":
        return TextArea(
            props.get("value", ""),
            language=props.get("language"),
            show_line_numbers=props.get("show_line_numbers", False),
            id=widget_id,
            classes=classes,
        )

    if kind == "option_list":
        items = props.get("items", [])
        return OptionList(*items, id=widget_id, classes=classes)

    if kind == "selection_list":
        items = props.get("items", [])
        select_items = [(item, item) for item in items]
        return SelectionList(*select_items, id=widget_id, classes=classes)

    # --- Navigation widgets ---
    if kind == "tabs":
        children = [build_widget(c) for c in children_specs]
        tc = TabbedContent(id=widget_id, classes=classes)
        for child in children:
            tc.compose_add_child(child)
        return tc

    if kind == "tab_pane":
        children = [build_widget(c) for c in children_specs]
        title = props.get("title", "Tab")
        return TabPane(title, *children, id=widget_id, classes=classes)

    if kind == "header":
        return Header(
            show_clock=props.get("show_clock", False),
            id=widget_id,
            classes=classes,
        )

    if kind == "footer":
        return Footer(id=widget_id, classes=classes)

    if kind == "collapsible":
        children = [build_widget(c) for c in children_specs]
        title = props.get("title", "")
        collapsed = props.get("collapsed", True)
        return Collapsible(
            *children,
            title=title,
            collapsed=collapsed,
            id=widget_id,
            classes=classes,
        )

    if kind == "content_switcher":
        children = [build_widget(c) for c in children_specs]
        initial = props.get("initial")
        return ContentSwitcher(
            *children,
            initial=initial,
            id=widget_id,
            classes=classes,
        )

    if kind == "tree":
        label = props.get("label", "Root")
        data = props.get("data", {})
        tree_widget = Tree(label, id=widget_id, classes=classes)
        _populate_tree(tree_widget.root, data)
        return tree_widget

    if kind == "directory_tree":
        path = props.get("path", ".")
        return DirectoryTree(path, id=widget_id, classes=classes)

    if kind == "masked_input":
        template = props.get("template", "")
        value = props.get("value")
        placeholder = props.get("placeholder", "")
        kwargs = dict(id=widget_id, classes=classes, placeholder=placeholder)
        if value is not None:
            kwargs["value"] = value
        return MaskedInput(template, **kwargs)

    if kind == "text_plot":
        try:
            from textual_plotext import PlotextPlot
        except ImportError:
            raise RtuiSpecError(
                "textual-plotext is not installed. "
                "Run: pip install textual-plotext"
            )
        return PlotextPlot(id=widget_id, classes=classes)

    raise RtuiSpecError(f"Unknown widget kind: {kind!r}")


def _parse_validators(specs):
    """Parse a list of validator spec strings into Textual Validator objects."""
    from textual.validation import Number, Integer, URL, Regex

    # Handle single string (R scalar) vs list
    if isinstance(specs, str):
        specs = [specs]

    validators = []
    for spec in specs:
        if spec == "number":
            validators.append(Number())
        elif spec == "integer":
            validators.append(Integer())
        elif spec == "url":
            validators.append(URL())
        elif spec.startswith("regex:"):
            pattern = spec[6:]
            validators.append(Regex(pattern))
        else:
            raise RtuiSpecError(f"Unknown validator: {spec!r}")
    return validators or None


def _populate_tree(node, data):
    if isinstance(data, dict):
        for key, value in data.items():
            if isinstance(value, dict):
                branch = node.add(key)
                _populate_tree(branch, value)
            elif isinstance(value, list):
                branch = node.add(key)
                for item in value:
                    if isinstance(item, dict):
                        _populate_tree(branch, item)
                    else:
                        branch.add_leaf(str(item))
            else:
                node.add_leaf(f"{key}: {value}")
    elif isinstance(data, list):
        for item in data:
            if isinstance(item, dict):
                _populate_tree(node, item)
            else:
                node.add_leaf(str(item))
