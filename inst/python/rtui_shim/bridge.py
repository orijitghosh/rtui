"""R callback bridge: marshals events between Textual and R."""

from __future__ import annotations

import time
from typing import Any, Callable, Optional


def make_event_dict(
    event_type: str,
    key: Optional[str] = None,
    widget_id: Optional[str] = None,
    value: Any = None,
    width: Optional[int] = None,
    height: Optional[int] = None,
    timer_id: Optional[str] = None,
) -> dict:
    return {
        "type": event_type,
        "key": key,
        "widget_id": widget_id,
        "value": value,
        "width": width,
        "height": height,
        "timer_id": timer_id,
    }
