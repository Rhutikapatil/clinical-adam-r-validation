# Clinical ADaM Programming & Validation in R

![R](https://img.shields.io/badge/R-Clinical%20Programming-276DC3?logo=r&logoColor=white)
![CDISC](https://img.shields.io/badge/ADaM--style-Analysis%20Datasets-356A98)
![XPT](https://img.shields.io/badge/XPT-SAS%20Transport-226B5C)
![Data](https://img.shields.io/badge/Data-100%25%20Synthetic-2E8B57)

A synthetic, R-based portfolio demonstration of selected clinical analysis dataset derivations and programmatic quality control. The workflow generates five **ADaM-style** datasets—ADSL, ADAE, ADLBSI, ADTTE, and ADEX—and exports SAS Transport (`.xpt`) files.

> **Public portfolio recreation:** All subject-level source data are generated synthetically. This repository is an educational demonstration of analysis-programming concepts, **not** the original clinical study, an officially CDISC-validated submission, or proof of independent validation against a confidential reference implementation.

## Project Highlights

- Builds SDTM-like synthetic source datasets with a reproducible seed
- Demonstrates subject-level treatment and safety flags (ADSL)
- Derives treatment-emergent adverse events and study days (ADAE)
- Selects laboratory baseline records and calculates change and percent change (ADLBSI)
- Implements illustrative event/censor logic for time-to-event endpoints (ADTTE)
- Removes duplicate dose-accountability records before exposure summaries (ADEX)
- Exports five datasets in SAS Transport (`.xpt`) format
- Checks dataset keys, derivation formulas, parameter categories, and XPT read-back structure

## Datasets

| Dataset | Demonstrated purpose |
|---|---|
| ADSL | Subject-level analysis data and treatment assignment |
| ADAE | Adverse event analysis and treatment-emergent flags |
| ADLBSI | Laboratory values, baseline, change and percent change |
| ADTTE | Illustrative PFS and OS event/censor derivations |
| ADEX | Exposure and dose-accountability summaries |

## Project Structure

```text
clinical-adam-r-validation/
├── R/
│   ├── 00_setup.R
│   ├── 01_generate_synthetic_data.R
│   ├── 02_build_adsl.R
│   ├── 03_build_adae.R
│   ├── 04_build_adlbsi.R
│   ├── 05_build_adtte.R
│   ├── 06_build_adex.R
│   ├── 07_validate_outputs.R
│   └── run_all.R
├── data/
│   ├── raw/       # Generated synthetic input; ignored by Git
│   └── output/    # Generated RDS and XPT files; ignored by Git
├── reports/       # Locally generated QC summaries; ignored by Git
└── README.md
```

## How to Run

Install R and the following R packages:

```r
install.packages(c("dplyr", "haven"))
```

From the repository's top-level directory in RStudio or R, run:

```r
source("R/run_all.R")
```

The pipeline generates synthetic SDTM-like source files in `data/raw/`, creates five analysis datasets, exports XPT and RDS outputs to `data/output/`, and writes validation summaries to `reports/`.

**Execution status:** This recreated package has undergone code-level review, but the full R pipeline has **not been execution-tested in the file-preparation environment**. Run it locally and review the QC report before describing it as successfully executed.

## Derivation and QC Notes

- **Laboratory baseline:** Latest eligible pre-treatment assessment; sequence number resolves same-day ties.
- **Percent change:** `100 * (AVAL - BASE) / BASE`, restricted to nonmissing, nonzero baseline values.
- **Exposure:** Removes duplicate accountability rows before calculating cumulative capsule count and illustrative dose summaries.
- **Time to event:** Synthetic example uses treatment end as a simplified observation cutoff. Real censoring rules must come from the applicable protocol and analysis plan.
- **Validation:** Checks core key/derivation conditions and verifies that XPT outputs can be read back with expected row counts and variable order. It does not compare against an independent programmer's reference datasets or perform full metadata/value equivalence testing.

## Skills Demonstrated

R · dplyr · haven · Clinical statistical programming · CDISC/ADaM concepts · Dataset derivations · Synthetic data generation · Time-to-event logic · XPT export · Programmatic QC

## Data and Confidentiality

This repository contains **no real trial data** and no original reference datasets, protocols, specifications, or sponsor identifiers. Local generated data and reports are excluded by `.gitignore`.
