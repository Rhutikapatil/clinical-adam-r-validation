# 07_validate_outputs.R
# Programmatic structural / derivation QC of synthetic datasets.
# Not a comparison with a confidential reference programmer's outputs.

adsl <- readRDS("data/output/ADSL.rds")
adae <- readRDS("data/output/ADAE.rds")
adlbsi <- readRDS("data/output/ADLBSI.rds")
adtte <- readRDS("data/output/ADTTE.rds")
adex <- readRDS("data/output/ADEX.rds")

checks <- c(
  "ADSL unique USUBJID" = nrow(adsl) == n_distinct(adsl$USUBJID),
  "ADSL treatment dates complete" = all(!is.na(adsl$TRTSDT)) &&
    all(!is.na(adsl$TRTEDT)),
  "ADAE identifiers complete" = all(!is.na(adae$USUBJID)),
  "ADLBSI baseline unique per subject/parameter" = {
    b <- adlbsi %>% filter(ABLFL == "Y")
    nrow(b) == nrow(distinct(b, USUBJID, PARAMCD))
  },
  "ADLBSI percent-change formula" = {
    z <- adlbsi %>%
      filter(!is.na(PCHG), !is.na(BASE), BASE != 0) %>%
      mutate(EXPECTED = ((AVAL - BASE) / BASE) * 100)
    all(abs(z$PCHG - z$EXPECTED) < 1e-10)
  },
  "ADTTE censoring indicator" = all(adtte$CNSR %in% c(0L, 1L)),
  "ADTTE positive duration" = all(!is.na(adtte$AVAL) & adtte$AVAL > 0),
  "ADEX four expected parameters" = setequal(
    unique(adex$PARAMCD), c("TXDUR", "CUMCAP", "CUMDOSE", "INTENS")
  ),
  "ADEX unique subject/parameter" = nrow(adex) ==
    nrow(distinct(adex, USUBJID, PARAMCD))
)

validation <- data.frame(CHECK = names(checks), PASS = as.logical(checks))
write.csv(validation, "reports/validation_summary.csv", row.names = FALSE)
cat("\nVALIDATION SUMMARY\n")
print(validation, row.names = FALSE)

rds_datasets <- list(ADSL = adsl, ADAE = adae, ADLBSI = adlbsi,
                     ADTTE = adtte, ADEX = adex)
readback <- lapply(names(rds_datasets), function(dataset) {
  path <- file.path("data", "output", paste0(dataset, ".xpt"))
  recovered <- if (file.exists(path))
    tryCatch(haven::read_xpt(path), error = function(e) NULL) else NULL
  original <- rds_datasets[[dataset]]
  data.frame(
    DATASET = dataset,
    FILE_EXISTS = file.exists(path),
    READABLE = !is.null(recovered),
    ROW_COUNT_MATCH = !is.null(recovered) && nrow(recovered) == nrow(original),
    VARIABLE_ORDER_MATCH = !is.null(recovered) &&
      identical(names(recovered), names(original))
  )
}) %>% bind_rows()
write.csv(readback, "reports/xpt_readback_summary.csv", row.names = FALSE)
cat("\nXPT READ-BACK\n")
print(readback, row.names = FALSE)

if (!all(validation$PASS) ||
    !all(readback$FILE_EXISTS & readback$READABLE &
         readback$ROW_COUNT_MATCH & readback$VARIABLE_ORDER_MATCH)) {
  stop("One or more validation checks failed. Review reports/ for details.")
}
cat("\nAll synthetic portfolio validation checks passed.\n")
