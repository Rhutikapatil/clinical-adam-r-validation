# 04_build_adlbsi.R

lb <- read.csv("data/raw/lb.csv", stringsAsFactors = FALSE) %>%

mutate(ADT = as.Date(LBDTC))

adsl <- readRDS("data/output/ADSL.rds")

lb_a <- lb %>%

left_join(

adsl %>% select(USUBJID, TRTSDT, TRT01P, TRT01PN, TRT01A, TRT01AN, SAFFL),

by = "USUBJID"

) %>%

mutate(

PARAMCD = LBTESTCD,

PARAM = LBTEST,

AVAL = LBSTRESN,

AVALU = LBSTRESU

)

# Baseline: latest eligible record strictly before treatment start.

# If the same date occurs more than once, largest LBSEQ wins.

baseline <- lb_a %>%

filter(!is.na(ADT), !is.na(TRTSDT), ADT < TRTSDT) %>%

arrange(USUBJID, PARAMCD, desc(ADT), desc(LBSEQ)) %>%

group_by(USUBJID, PARAMCD) %>%

slice(1) %>%

ungroup() %>%

transmute(

USUBJID,

PARAMCD,

BASE = AVAL,

BASEDT = ADT,

BASESEQ = LBSEQ

)

adlbsi <- lb_a %>%

left_join(baseline, by = c("USUBJID", "PARAMCD")) %>%

mutate(

ABLFL = ifelse(ADT == BASEDT & LBSEQ == BASESEQ, "Y", NA_character_),

CHG = ifelse(!is.na(BASE) & ADT > TRTSDT, AVAL - BASE, NA_real_),

PCHG = ifelse(

!is.na(BASE) & BASE != 0 & ADT > TRTSDT,

((AVAL - BASE) / BASE) * 100,

NA_real_

)

)

write_xpt(adlbsi, "data/output/ADLBSI.xpt", version = 5)

saveRDS(adlbsi, "data/output/ADLBSI.rds")

cat("ADLBSI created:", nrow(adlbsi), "rows x", ncol(adlbsi), "columns\n")
