# 03_build_adae.R

ae <- read.csv("data/raw/ae.csv", stringsAsFactors = FALSE) %>%

mutate(

ASTDT = as.Date(ASTDT),

AENDT = as.Date(AENDT)

)

adsl <- readRDS("data/output/ADSL.rds")

adae <- ae %>%

left_join(

adsl %>%

select(

USUBJID, TRTSDT, TRTEDT, TRT01P, TRT01PN,

TRT01A, TRT01AN, ITTFL, SAFFL

),

by = "USUBJID"

) %>%

mutate(

TRTEMFL = ifelse(

!is.na(ASTDT) &

ASTDT >= TRTSDT &

ASTDT <= TRTEDT + 30,

"Y", "N"

),

ASTDY = ifelse(

!is.na(ASTDT),

as.integer(ASTDT - TRTSDT) + ifelse(ASTDT >= TRTSDT, 1L, 0L),

NA_integer_

),

AENDY = ifelse(

!is.na(AENDT),

as.integer(AENDT - TRTSDT) + ifelse(AENDT >= TRTSDT, 1L, 0L),

NA_integer_

)

)

write_xpt(adae, "data/output/ADAE.xpt", version = 5)

saveRDS(adae, "data/output/ADAE.rds")

cat("ADAE created:", nrow(adae), "rows x", ncol(adae), "columns\n")
