# 01_generate_synthetic_data.R

# Generates small, synthetic SDTM-like source datasets.

# No real clinical data are used.

set.seed(42)

n_subj <- 20

usubjid <- sprintf("DEMO-%03d", seq_len(n_subj))

trt <- rep(c("Active", "Placebo"), length.out = n_subj)

dm <- data.frame(

STUDYID = "DEMO-STUDY",

USUBJID = usubjid,

SUBJID = sprintf("%03d", seq_len(n_subj)),

SITEID = sprintf("%02d", sample(1:4, n_subj, replace = TRUE)),

AGE = sample(40:78, n_subj, replace = TRUE),

AGEU = "YEARS",

SEX = sample(c("F", "M"), n_subj, replace = TRUE),

RACE = sample(c("WHITE", "BLACK OR AFRICAN AMERICAN", "ASIAN"), n_subj, replace = TRUE),

ETHNIC = sample(c("NOT HISPANIC OR LATINO", "HISPANIC OR LATINO"), n_subj, replace = TRUE),

COUNTRY = "USA",

ARM = trt,

stringsAsFactors = FALSE

)

trt_start <- as.Date("2026-01-01") + sample(0:14, n_subj, replace = TRUE)

trt_end <- trt_start + sample(70:120, n_subj, replace = TRUE)

ex <- data.frame(

STUDYID = "DEMO-STUDY",

USUBJID = rep(usubjid, each = 4),

EXSEQ = rep(1:4, times = n_subj),

EXTRT = rep(trt, each = 4),

EXSTDTC = as.character(rep(trt_start, each = 4) + rep(c(0, 28, 56, 84), times = n_subj)),

EXENDTC = as.character(rep(trt_start, each = 4) + rep(c(27, 55, 83, 111), times = n_subj)),

stringsAsFactors = FALSE

)

ae_n <- 70

ae <- data.frame(

STUDYID = "DEMO-STUDY",

USUBJID = sample(usubjid, ae_n, replace = TRUE),

AESEQ = seq_len(ae_n),

AETERM = sample(

c("Headache", "Nausea", "Fatigue", "Dizziness", "Rash"),

ae_n, replace = TRUE

),

AEDECOD = sample(

c("HEADACHE", "NAUSEA", "FATIGUE", "DIZZINESS", "RASH"),

ae_n, replace = TRUE

),

AESEV = sample(c("MILD", "MODERATE", "SEVERE"), ae_n, replace = TRUE),

AESER = sample(c("Y", "N"), ae_n, replace = TRUE, prob = c(0.08, 0.92)),

ASTDT = sample(trt_start, ae_n, replace = TRUE) + sample(-5:100, ae_n, replace = TRUE),

AENDT = as.Date(NA),

stringsAsFactors = FALSE

)

ae$AENDT <- ae$ASTDT + sample(1:12, ae_n, replace = TRUE)

# Laboratory records: one pre-treatment record + several post-treatment records

lb_rows <- list()

seq_counter <- 1L

for (i in seq_len(n_subj)) {

dates <- trt_start[i] + c(-7, 14, 42, 70)

for (param in c("ALT", "AST", "BILI")) {

vals <- switch(

param,

ALT = round(rnorm(4, 30, 8), 1),

AST = round(rnorm(4, 28, 7), 1),

BILI = round(rnorm(4, 0.8, 0.2), 2)

)

for (j in seq_along(dates)) {

lb_rows[[length(lb_rows) + 1]] <- data.frame(

STUDYID = "DEMO-STUDY",

USUBJID = usubjid[i],

LBSEQ = seq_counter,

LBTESTCD = param,

LBTEST = param,

LBDTC = as.character(dates[j]),

LBSTRESN = vals[j],

LBSTRESU = ifelse(param == "BILI", "mg/dL", "U/L"),

stringsAsFactors = FALSE

)

seq_counter <- seq_counter + 1L

}

}

}

lb <- bind_rows(lb_rows)

# Dose accountability records. Add one exact duplicate deliberately.

da <- data.frame(

STUDYID = "DEMO-STUDY",

USUBJID = rep(usubjid, each = 4),

DASEQ = rep(1:4, times = n_subj),

DATESTCD = "TAKENAMT",

DARFTDTC = as.character(rep(trt_start, each = 4) + rep(c(0, 28, 56, 84), times = n_subj)),

DADTC = as.character(rep(trt_start, each = 4) + rep(c(27, 55, 83, 111), times = n_subj)),

DAORRES = as.character(sample(40:60, n_subj * 4, replace = TRUE)),

DASTRESN = sample(40:60, n_subj * 4, replace = TRUE),

stringsAsFactors = FALSE

)

da$DASTRESN <- as.numeric(da$DAORRES)

da <- bind_rows(da, da[1, ])

# Simple progression / death dates for time-to-event demonstration

tte_source <- data.frame(

STUDYID = "DEMO-STUDY",

USUBJID = usubjid,

TRTSDT = trt_start,

TRTEDT = trt_end,

PROGDT = trt_start + sample(c(60:160, rep(NA_integer_, 40)), n_subj, replace = TRUE),

DEATHDT = trt_start + sample(c(90:200, rep(NA_integer_, 60)), n_subj, replace = TRUE),

stringsAsFactors = FALSE

)

write.csv(dm, "data/raw/dm.csv", row.names = FALSE, na = "")

write.csv(ex, "data/raw/ex.csv", row.names = FALSE, na = "")

write.csv(ae, "data/raw/ae.csv", row.names = FALSE, na = "")

write.csv(lb, "data/raw/lb.csv", row.names = FALSE, na = "")

write.csv(da, "data/raw/da.csv", row.names = FALSE, na = "")

write.csv(tte_source, "data/raw/tte_source.csv", row.names = FALSE, na = "")

cat("Synthetic source data created.\n")
