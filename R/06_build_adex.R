# 06_build_adex.R

da <- read.csv("data/raw/da.csv", stringsAsFactors = FALSE)

adsl <- readRDS("data/output/ADSL.rds")

# Remove duplicate accountability records using the analysis key.

da_dedup <- da %>%

distinct(

USUBJID, DARFTDTC, DADTC, DATESTCD, DAORRES,

.keep_all = TRUE

)

cumcap <- da_dedup %>%

filter(DATESTCD == "TAKENAMT") %>%

group_by(USUBJID) %>%

summarise(

CUMCAP = sum(DASTRESN, na.rm = TRUE),

.groups = "drop"

)

subject <- adsl %>%

left_join(cumcap, by = "USUBJID") %>%

mutate(

DAYS_ON_TREATMENT = as.integer(TRTEDT - TRTSDT) + 1L

)

txdur <- subject %>%

transmute(

STUDYID, USUBJID,

PARAM = "Duration of Treatment Received (months)",

PARAMCD = "TXDUR",

AVAL = DAYS_ON_TREATMENT / 30.4375,

DTYPE = "DIFFERENCE",

TRTSDT, TRTEDT, TRT01P, TRT01PN, TRT01A, TRT01AN

)

cumcap_ds <- subject %>%

transmute(

STUDYID, USUBJID,

PARAM = "Total Number of Capsules Taken",

PARAMCD = "CUMCAP",

AVAL = CUMCAP,

DTYPE = "SUM",

TRTSDT, TRTEDT, TRT01P, TRT01PN, TRT01A, TRT01AN

)

cumdose <- subject %>%

transmute(

STUDYID, USUBJID,

PARAM = "Total Cumulative Dose (g)",

PARAMCD = "CUMDOSE",

AVAL = (CUMCAP * 150) / 1000,

DTYPE = "SUM",

TRTSDT, TRTEDT, TRT01P, TRT01PN, TRT01A, TRT01AN

)

intens <- subject %>%

transmute(

STUDYID, USUBJID,

PARAM = "Dose Intensity (%)",

PARAMCD = "INTENS",

AVAL = (CUMCAP / DAYS_ON_TREATMENT) * 100,

DTYPE = "PERCENTAGE",

TRTSDT, TRTEDT, TRT01P, TRT01PN, TRT01A, TRT01AN

)

adex <- bind_rows(txdur, cumcap_ds, cumdose, intens) %>%

arrange(PARAMCD, USUBJID)

write_xpt(adex, "data/output/ADEX.xpt", version = 5)

saveRDS(adex, "data/output/ADEX.rds")

cat("ADEX created:", nrow(adex), "rows x", ncol(adex), "columns\n")

cat("Duplicate DA rows removed:", nrow(da) - nrow(da_dedup), "\n")
