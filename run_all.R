# run_all.R

# Execute the full synthetic portfolio pipeline.

source("R/00_setup.R")

source("R/01_generate_synthetic_data.R")

source("R/02_build_adsl.R")

source("R/03_build_adae.R")

source("R/04_build_adlbsi.R")

source("R/05_build_adtte.R")

source("R/06_build_adex.R")

source("R/07_validate_outputs.R")

cat("\nPipeline complete.\n")
