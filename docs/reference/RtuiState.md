# Mutable TUI state object

Mutable TUI state object

Mutable TUI state object

## Details

An R6 class for managing mutable app state. Created by
[`tui_state()`](tui_state.md). Supports reactive bindings that
auto-update widgets when values change.

## Active bindings

- `data`:

  Access the raw state data list.

- `app`:

  Access the running app (for calling [`update()`](update.md), etc.)

## Methods

### Public methods

- [`RtuiState$new()`](#method-RtuiState-new)

- [`RtuiState$get()`](#method-RtuiState-get)

- [`RtuiState$set()`](#method-RtuiState-set)

- [`RtuiState$as_list()`](#method-RtuiState-as_list)

- [`RtuiState$print()`](#method-RtuiState-print)

- [`RtuiState$clone()`](#method-RtuiState-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new state object.

#### Usage

    RtuiState$new(initial = list())

#### Arguments

- `initial`:

  A list of initial state values.

------------------------------------------------------------------------

### Method [`get()`](https://rdrr.io/r/base/get.html)

Get a value by key.

#### Usage

    RtuiState$get(key, default = NULL)

#### Arguments

- `key`:

  Character string key.

- `default`:

  Value to return if key is not found.

------------------------------------------------------------------------

### Method `set()`

Set a value by key. Fires reactive bindings if the value changed.

#### Usage

    RtuiState$set(key, value)

#### Arguments

- `key`:

  Character string key.

- `value`:

  The value to store.

------------------------------------------------------------------------

### Method `as_list()`

Return state as a plain list (excluding internal keys).

#### Usage

    RtuiState$as_list()

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print the state object.

#### Usage

    RtuiState$print(...)

#### Arguments

- `...`:

  Ignored.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    RtuiState$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
