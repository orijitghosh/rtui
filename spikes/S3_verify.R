# Spike S3 Step 2: Verify the r-rtui virtualenv has working textual + rich.
#
# Run in a FRESH R session (restart R first):
#   source("spikes/S3_verify.R")

envname <- "r-rtui"

# Point reticulate at the venv BEFORE loading/initializing Python
Sys.setenv(RETICULATE_PYTHON_ENV = envname)
library(reticulate)
use_virtualenv(envname, required = TRUE)

message("--- S3 Step 2: Verify imports ---")
message(sprintf("Python: %s", py_config()$python))

tryCatch(
  {
    textual <- import("textual")
    rich_meta <- import("importlib.metadata")

    tv <- textual$`__version__`
    rv <- rich_meta$version("rich")

    message(sprintf("  textual version: %s", tv))
    message(sprintf("  rich version: %s", rv))

    if (grepl("^0\\.85", tv)) {
      message("S3 RESULT: SUCCESS - pinned textual installed and importable")
    } else {
      message(sprintf("S3 RESULT: WARNING - expected 0.85.x, got %s", tv))
    }
  },
  error = function(e) {
    message("S3 RESULT: FAILURE - ", conditionMessage(e))
  }
)
