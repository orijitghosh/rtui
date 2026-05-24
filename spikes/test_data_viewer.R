# Showcase: data_viewer() — one-liner interactive data exploration
#
# Run from a REAL TERMINAL:
#   & "C:\Program Files\R\R-4.4.3\bin\Rscript.exe" spikes/test_data_viewer.R

Sys.unsetenv("RETICULATE_PYTHON")
Sys.setenv(RETICULATE_PYTHON_ENV = "r-rtui")

library(reticulate)
use_virtualenv("r-rtui", required = TRUE)

devtools::load_all(".")

message("--- Launching data viewer for mtcars (press q or escape to quit) ---")

# ONE LINE to interactively explore any data.frame:
data_viewer(mtcars)

message("--- Data viewer exited ---")
