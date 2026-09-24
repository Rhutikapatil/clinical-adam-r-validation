# 02_build_adsl.R

dm <- read.csv("data/raw/dm.csv", stringsAsFactors = FALSE)

ex <- read.csv("data/raw/ex.csv", stringsAsFactors = FALSE)

ex_dates <- ex %>%

mutate(

EXSTDTC = as.Date(EXSTDTC),

EXENDTC = as.Date(EXENDTC)

) %>%

group_by(USUBJID) %>%

summarise(

TRTSDT = min(EXSTDTC, na.rm = TRUE),

TRTEDT = max(EXENDTC, na.rm = TRUE),

.groups = "drop"

)

adsl <- dm %>%

left_join(ex_dates, by = "USUBJID") %>%

mutate(

AGEGR1 = case_when(

AGE < 50 ~ "<50",

AGE < 65 ~ "50-64",

TRUE ~ "65+"

),

AGEGR1N = case_when(

AGE < 50 ~ 1,

AGE < 65 ~ 2,

TRUE ~ 3

),

TRT01P = ARM,

TRT01A = ARM,

TRT01PN = ifelse(TRT01P == "Active", 1, 0),

TRT01AN = ifelse(TRT01A == "Active", 1, 0),

ITTFL = "Y",

SAFFL = "Y"

) %>%

select(

STUDYID, USUBJID, SUBJID, SITEID,

AGE, AGEU, AGEGR1, AGEGR1N, SEX, RACE, ETHNIC, COUNTRY,

TRTSDT, TRTEDT,

TRT01P, TRT01PN, TRT01A, TRT01AN,

ITTFL, SAFFL

)

write_xpt(adsl, "data/output/ADSL.xpt", version = 5)

saveRDS(adsl, "data/output/ADSL.rds")

cat("ADSL created:", nrow(adsl), "rows x", ncol(adsl), "columns\n")
