# 00_setup.R

# Minimal setup for the synthetic ADaM portfolio project.

required_packages <- c("dplyr", "haven")

missing_packages <- required_packages[

!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)

]

if (length(missing_packages) > 0) {

stop(

"Install required packages before running: ",

paste(missing_packages, collapse = ", ")

)

}

suppressPackageStartupMessages({

library(dplyr)

library(haven)

})

dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)

dir.create("data/output", recursive = TRUE, showWarnings = FALSE)

dir.create("reports", recursive = TRUE, showWarnings = FALSE)

cat("Setup complete.\n")
