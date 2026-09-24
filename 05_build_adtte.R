# 05_build_adtte.R
# Illustrative PFS / OS derivations using synthetic source data.
# This demonstration uses treatment end as the observation cutoff for both
# endpoints; real analyses must use protocol- and SAP-specific censoring rules.

tte <- read.csv("data/raw/tte_source.csv", stringsAsFactors = FALSE) %>%
  mutate(
    TRTSDT = as.Date(TRTSDT),
    TRTEDT = as.Date(TRTEDT),
    PROGDT = as.Date(PROGDT),
    DEATHDT = as.Date(DEATHDT)
  )
adsl <- readRDS("data/output/ADSL.rds")

# pmin(..., na.rm=TRUE) would yield Inf if both event dates are missing.
# Convert event dates to numeric and explicitly handle Inf and cutoff dates.
progression_num <- ifelse(is.na(tte$PROGDT), Inf, as.numeric(tte$PROGDT))
death_num <- ifelse(is.na(tte$DEATHDT), Inf, as.numeric(tte$DEATHDT))
pfs_event_num <- pmin(progression_num, death_num)
pfs_valid <- is.finite(pfs_event_num) &
  pfs_event_num >= as.numeric(tte$TRTSDT) &
  pfs_event_num <= as.numeric(tte$TRTEDT)

pfs <- tte %>%
  mutate(
    PARAMCD = "PFS",
    PARAM = "Progression-Free Survival",
    CNSR = ifelse(pfs_valid, 0L, 1L),
    ADT = as.Date(ifelse(pfs_valid, pfs_event_num,
                         as.numeric(TRTEDT)), origin = "1970-01-01"),
    AVAL = as.integer(ADT - TRTSDT) + 1L,
    EVNTDESC = ifelse(CNSR == 0L, "Progression or Death", "Censored")
  )

os_valid <- !is.na(tte$DEATHDT) & tte$DEATHDT >= tte$TRTSDT &
  tte$DEATHDT <= tte$TRTEDT
os <- tte %>%
  mutate(
    PARAMCD = "OS",
    PARAM = "Overall Survival",
    CNSR = ifelse(os_valid, 0L, 1L),
    ADT = as.Date(ifelse(os_valid, as.numeric(DEATHDT),
                         as.numeric(TRTEDT)), origin = "1970-01-01"),
    AVAL = as.integer(ADT - TRTSDT) + 1L,
    EVNTDESC = ifelse(CNSR == 0L, "Death", "Censored")
  )

adtte <- bind_rows(pfs, os) %>%
  left_join(
    adsl %>% select(USUBJID, TRT01P, TRT01PN, TRT01A, TRT01AN, ITTFL, SAFFL),
    by = "USUBJID"
  ) %>%
  select(
    STUDYID, USUBJID, PARAM, PARAMCD, TRTSDT, TRTEDT,
    ADT, AVAL, CNSR, EVNTDESC, TRT01P, TRT01PN, TRT01A, TRT01AN,
    ITTFL, SAFFL
  )

stopifnot(all(!is.na(adtte$AVAL) & adtte$AVAL > 0))
haven::write_xpt(adtte, "data/output/ADTTE.xpt", version = 5)
saveRDS(adtte, "data/output/ADTTE.rds")
cat("ADTTE created:", nrow(adtte), "rows x", ncol(adtte), "columns\n")
