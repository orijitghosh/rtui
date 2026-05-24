# Install Python dependencies for rtui

Creates a dedicated virtualenv and installs pinned Textual requirements.

## Usage

``` r
install_python_deps(envname = "r-rtui", python = NULL)
```

## Arguments

- envname:

  Name of the virtualenv (default: "r-rtui").

- python:

  Path to a Python interpreter. If `NULL`, uses reticulate's default
  discovery. On Windows, the Microsoft Store Python is not supported;
  provide a path to a python.org install (e.g., Python 3.12).

## Value

Invisible `TRUE` on success.
