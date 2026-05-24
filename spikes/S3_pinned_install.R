# Spike S3: Does pinning textual==0.85.* install cleanly under reticulate?
#
# TWO STEPS (each requires a fresh R session):
#
# Step 1 — Install (run once, fresh R session):
#   source("spikes/S3_pinned_install.R")
#
# Step 2 — Verify (restart R, then):
#   source("spikes/S3_verify.R")

python_path <- "C:/Users/ariji/AppData/Local/Programs/Python/Python312/python.exe"
envname <- "r-rtui"

Sys.setenv(RETICULATE_PYTHON = python_path)
library(reticulate)

message("--- S3 Step 1: Install pinned Python dependencies ---")
message(sprintf("Using Python: %s", python_path))

if (virtualenv_exists(envname)) {
  message("Removing existing virtualenv...")
  virtualenv_remove(envname, confirm = FALSE)
}

message("Creating virtualenv and installing deps...")
tryCatch(
  {
    virtualenv_create(envname, python = python_path)
    virtualenv_install(envname, packages = c("textual==0.85.2", "rich>=13.7,<14"))
    message("")
    message("S3 Step 1: DONE - packages installed.")
    message("Now restart R and run: source('spikes/S3_verify.R')")
  },
  error = function(e) {
    message("S3 RESULT: FAILURE - ", conditionMessage(e))
  }
)
